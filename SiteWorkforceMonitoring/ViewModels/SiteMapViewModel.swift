import SwiftUI
import Combine
import FirebaseFirestore
import MapKit
import CoreLocation
import UserNotifications

@MainActor
final class SiteMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var projects: [ConstructionProject] = []
    @Published var attendance: [AttendanceRecord] = []
    @Published var selectedProjectName: String? = nil
    @Published var searchText = ""
    @Published var selectedStatus = "All"
    
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    @Published var travelTime: String?
    @Published var distanceText: String?
    
    @Published var activeGeofenceAlert: String? = nil
    @Published var isInsideGeofence: Bool = false
    @Published var hoverStateByProject: [String: Bool] = [:]

    let statusOptions = ["All", "Present", "Late", "Absent"]
    let geofenceRadiusMeters: CLLocationDistance = 150.0
    
    private let db = Firestore.firestore()
    private var projectsListener: ListenerRegistration?
    private var attendanceListener: ListenerRegistration?
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        requestNotificationPermission()
        setupLocationManager()
        fetchProjects()
        fetchAttendance()
    }

    deinit {
        projectsListener?.remove()
        attendanceListener?.remove()
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Notification Permission Error: \(error.localizedDescription)")
            } else {
                print("🔔 Notification Permission Granted: \(granted)")
            }
        }
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func fetchProjects() {
        projectsListener = db.collection("projects").addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print("❌ Firestore Project Error: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            self?.projects = documents.compactMap { doc in
                do {
                    return try doc.data(as: ConstructionProject.self)
                } catch {
                    print("⚠️ Failed to decode project doc \(doc.documentID): \(error)")
                    return nil
                }
            }
        }
    }

    func fetchAttendance() {
        attendanceListener = db.collection("attendance").addSnapshotListener { [weak self] snapshot, error in
            if let error = error {
                print("❌ Firestore Attendance Error: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            self?.attendance = documents.compactMap { doc in
                do {
                    return try doc.data(as: AttendanceRecord.self)
                } catch {
                    print("⚠️ Failed to decode attendance doc \(doc.documentID): \(error)")
                    return nil
                }
            }
        }
    }

    var selectedProject: ConstructionProject? {
        projects.first { $0.name == selectedProjectName }
    }

    var currentSiteWorkerCount: Int {
        guard let selectedName = selectedProjectName else {
            return projects.reduce(0) { $0 + ($1.workersAssigned ?? 0) }
        }
        return attendance.filter { record in
            record.siteId.localizedCaseInsensitiveContains(selectedName)
        }.count
    }

    var filteredAttendance: [AttendanceRecord] {
        attendance.filter { record in
            let matchesSearch = searchText.isEmpty ||
                record.workerName.localizedCaseInsensitiveContains(searchText) ||
                record.siteId.localizedCaseInsensitiveContains(searchText)

            let matchesStatus = selectedStatus == "All" || record.status.rawValue == selectedStatus
            
            let matchesProject: Bool = {
                guard let selectedName = selectedProjectName else { return true }
                let matchingProject = projects.first { $0.name == selectedName }
                
                return record.siteId == selectedName ||
                       record.siteId == matchingProject?.projectId ||
                       record.siteId.localizedCaseInsensitiveContains(selectedName) ||
                       selectedName.localizedCaseInsensitiveContains(record.siteId)
            }()

            return matchesSearch && matchesStatus && matchesProject
        }
    }

    func calculateRoute(to destination: CLLocationCoordinate2D) {
        guard let userLoc = userLocation else {
            let fallbackUser = CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612)
            requestDirections(from: fallbackUser, to: destination)
            return
        }
        requestDirections(from: userLoc, to: destination)
    }

    private func requestDirections(from start: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        
        let startPlacemark = MKPlacemark(coordinate: start)
        let destPlacemark = MKPlacemark(coordinate: destination)
        
        request.source = MKMapItem(placemark: startPlacemark)
        request.destination = MKMapItem(placemark: destPlacemark)
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            if let error = error {
                print("❌ Route calculation error: \(error.localizedDescription)")
                return
            }
            
            guard let route = response?.routes.first else {
                print("⚠️ No route returned by MKDirections")
                return
            }
            
            Task { @MainActor [weak self] in
                self?.routeCoordinates = route.polyline.coordinates
                let formatter = DateComponentsFormatter()
                formatter.unitsStyle = .abbreviated
                formatter.allowedUnits = [.hour, .minute]
                self?.travelTime = formatter.string(from: route.expectedTravelTime)
                
                let distanceKm = route.distance / 1000.0
                self?.distanceText = String(format: "%.1f km", distanceKm)
            }
        }
    }

    func evaluateGeofence(for userLoc: CLLocationCoordinate2D) {
        guard let project = selectedProject else {
            isInsideGeofence = false
            activeGeofenceAlert = nil
            return
        }

        let siteLocation = CLLocation(latitude: project.coordinate.latitude, longitude: project.coordinate.longitude)
        let currentLocation = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        
        let distanceMeters = currentLocation.distance(from: siteLocation)

        if distanceMeters <= geofenceRadiusMeters {
            if !isInsideGeofence {
                isInsideGeofence = true
                let alertMessage = "Worker entered pre-defined site zone for \(project.name)"
                activeGeofenceAlert = alertMessage
                sendLocalNotification(title: "Site Geofence Alert", body: alertMessage)
            }
        } else {
            if isInsideGeofence {
                isInsideGeofence = false
                let alertMessage = "Worker went outside pre-defined site zone for \(project.name)"
                activeGeofenceAlert = alertMessage
                sendLocalNotification(title: "Site Geofence Alert", body: alertMessage)
            }
        }
    }

    func handleHover(isHovered: Bool, for project: ConstructionProject) {
        hoverStateByProject[project.name] = isHovered
        
        if isHovered {
            isInsideGeofence = true
            let alertMessage = "Worker entered pre-defined site zone for \(project.name)"
            activeGeofenceAlert = alertMessage
            sendLocalNotification(title: "Pointer Geofence Entry", body: alertMessage)
        } else {
            if selectedProjectName == project.name {
                isInsideGeofence = false
                let alertMessage = "Worker went outside pre-defined site zone for \(project.name)"
                activeGeofenceAlert = alertMessage
                sendLocalNotification(title: "Pointer Geofence Exit", body: alertMessage)
            }
        }
    }

    private func sendLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule local notification: \(error.localizedDescription)")
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.userLocation = location.coordinate
            self.evaluateGeofence(for: location.coordinate)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
}

extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}

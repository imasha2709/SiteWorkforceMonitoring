import SwiftUI
import Combine
import FirebaseFirestore
import MapKit
import CoreLocation

@MainActor
final class SiteMapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var projects: [ConstructionProject] = []
    @Published var attendance: [AttendanceRecord] = []
    @Published var selectedProjectName: String? = nil
    @Published var searchText = ""
    @Published var selectedStatus = "All"
    
    // Map & Navigation State
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    @Published var travelTime: String?
    @Published var distanceText: String?
    
    // Geofence & Proximity Alert State
    @Published var activeGeofenceAlert: String? = nil
    @Published var isInsideGeofence: Bool = false

    let statusOptions = ["All", "Present", "Late", "Absent"]
    let geofenceRadiusMeters: CLLocationDistance = 150.0
    
    private let db = Firestore.firestore()
    private var projectsListener: ListenerRegistration?
    private var attendanceListener: ListenerRegistration?
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        setupLocationManager()
        fetchProjects()
        fetchAttendance()
    }

    deinit {
        projectsListener?.remove()
        attendanceListener?.remove()
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

    // MARK: - Route Calculation (Directions)
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
        
        let startLocation = CLLocation(latitude: start.latitude, longitude: start.longitude)
        let destLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        
        request.source = MKMapItem(location: startLocation, address: nil)
        request.destination = MKMapItem(location: destLocation, address: nil)
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let route = response?.routes.first else { return }
            DispatchQueue.main.async {
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

    // MARK: - Geofence Evaluation
    private func evaluateGeofence(for userLoc: CLLocationCoordinate2D) {
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
                activeGeofenceAlert = "Entered geofence zone for \(project.name)"
            }
        } else {
            if isInsideGeofence {
                isInsideGeofence = false
                activeGeofenceAlert = "Exited geofence zone for \(project.name)"
            }
        }
    }

    // MARK: - CLLocationManagerDelegate
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

// MARK: - Helper Extension for Polyline coordinates
extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}

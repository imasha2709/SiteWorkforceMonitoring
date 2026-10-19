import Foundation
import CoreLocation

enum AttendanceStatus: String, CaseIterable, Identifiable {
    case present = "Present"
    case late = "Late"
    case absent = "Absent"
    var id: String { rawValue }
}

struct Worker: Identifiable {
    let id: UUID
    var name: String
    var role: String
    var site: String
    var status: AttendanceStatus
    var initials: String
    
    init(id: UUID = UUID(), name: String, role: String, site: String, status: AttendanceStatus, initials: String) {
        self.id = id
        self.name = name
        self.role = role
        self.site = site
        self.status = status
        self.initials = initials
    }
}

struct ProjectTask: Identifiable, Codable {
    let id = UUID()
    let title: String
    let isCompleted: Bool
    let priority: String
}

struct ConstructionProject: Identifiable, Codable {
    let id: UUID
    let name: String
    let location: String
    var latitude: Double
    var longitude: Double
    let progress: Double
    let status: String
    let workersAssigned: Int
    let imageName: String
    let description: String
    let tasks: [ProjectTask]
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(id: UUID = UUID(), name: String, location: String, coordinate: CLLocationCoordinate2D, progress: Double, status: String, workersAssigned: Int, imageName: String, description: String, tasks: [ProjectTask]) {
        self.id = id
        self.name = name
        self.location = location
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.progress = progress
        self.status = status
        self.workersAssigned = workersAssigned
        self.imageName = imageName
        self.description = description
        self.tasks = tasks
    }
}

struct AttendanceRecord: Identifiable {
    let id: UUID
    var workerName: String
    var site: String
    var checkIn: String
    var status: AttendanceStatus
    
    init(id: UUID = UUID(), workerName: String, site: String, checkIn: String, status: AttendanceStatus) {
        self.id = id
        self.workerName = workerName
        self.site = site
        self.checkIn = checkIn
        self.status = status
    }
}

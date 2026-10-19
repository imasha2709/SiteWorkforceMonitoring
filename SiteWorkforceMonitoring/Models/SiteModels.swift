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

struct ConstructionProject: Identifiable {
    let id: UUID
    var name: String
    var location: String
    var progress: Double
    var status: String
    var workersAssigned: Int
    var coordinate: CLLocationCoordinate2D
    
    init(id: UUID = UUID(), name: String, location: String, progress: Double, status: String, workersAssigned: Int, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.name = name
        self.location = location
        self.progress = progress
        self.status = status
        self.workersAssigned = workersAssigned
        self.coordinate = coordinate
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


import Foundation

enum UserRole: String, CaseIterable, Identifiable {
    case projectManager = "Project Manager"
    case siteSupervisor = "Site Supervisor"
    case siteWorker = "Site Worker"

    var id: String { rawValue }

    var canViewWorkers: Bool {
        self == .projectManager || self == .siteSupervisor
    }

    var canManageWorkers: Bool {
        self == .projectManager
    }

    var canViewAllProjects: Bool {
        self == .projectManager
    }

    var canManageAttendance: Bool {
        self == .projectManager || self == .siteSupervisor
    }
}

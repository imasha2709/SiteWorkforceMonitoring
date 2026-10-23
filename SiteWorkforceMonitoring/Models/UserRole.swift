import Foundation

enum UserRole: String, CaseIterable, Identifiable, Codable {
    case projectManager = "Project Manager"

    var id: String { rawValue }

    var canViewWorkers: Bool { true }
    var canManageWorkers: Bool { true }
    var canManageProjects: Bool { true }
    var canViewAllProjects: Bool { true }
    var canManageAttendance: Bool { true }
}

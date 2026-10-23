import Foundation

struct ProjectTask: Identifiable {
    var id: String
    var taskId: String
    var projectId: String
    var title: String
    var description: String
    var status: String
    var completed: Bool
    var progress: Double
}
import Foundation

struct AlertItem: Identifiable {
    var id: String
    var title: String
    var message: String
    var projectId: String
    var type: String
    var severity: String
    var isRead: Bool
    var createdAt: Date
}
import Foundation

struct ConstructionProject: Identifiable {
    var id: String
    var projectId: String
    var name: String
    var location: String
    var progress: Double
    var status: String
    var managerName: String
}
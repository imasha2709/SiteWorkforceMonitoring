import Foundation
import FirebaseFirestore
import CoreLocation

// MARK: - Task Model (Matches Firestore `tasks` collection)
struct ProjectTask: Identifiable, Codable {
    @DocumentID var id: String?
    var taskId: String?
    var projectId: String?
    var title: String
    var description: String?
    var status: String?
    var isCompleted: Bool
    var progress: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case taskId = "taskId"
        case projectId = "projectId"
        case title
        case description
        case status
        case isCompleted = "completes"
        case progress = "Progress"
    }
}

// MARK: - Construction Project Model
struct ConstructionProject: Identifiable, Codable {
    @DocumentID var id: String?
    var projectId: String
    var name: String
    var location: String? // ✅ Made optional so missing Firestore fields won't crash decoding
    var progress: Double
    var status: String
    var managerName: String
    
    var imageName: String?
    var description: String?
    var startDate: String?
    var expectedCompletionDate: String?
    var workersAssigned: Int?
    var latitude: Double?
    var longitude: Double?
    var tasks: [ProjectTask]?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude ?? 6.9271,
            longitude: longitude ?? 79.8612
        )
    }

    enum CodingKeys: String, CodingKey {
        case id
        case projectId
        case name
        case location
        case progress
        case status
        case managerName
        case imageName
        case description
        case startDate
        case expectedCompletionDate
        case workersAssigned
        case latitude
        case longitude
        case tasks
    }
}

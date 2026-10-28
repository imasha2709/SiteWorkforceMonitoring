import Foundation
import FirebaseFirestore


enum AttendanceStatus: String, Codable, CaseIterable, Identifiable {
    case present = "Present"
    case late = "Late"
    case absent = "Absent"
    
    var id: String { rawValue }
}


struct AttendanceRecord: Identifiable, Codable {
    @DocumentID var id: String?
    var worker: String?
    var workerName: String
    var projectId: String?
    var siteId: String
    var date: Date?
    var status: AttendanceStatus
    var checkIn: Timestamp?
    var checkOut: Timestamp?
    
    enum CodingKeys: String, CodingKey {
        case id
        case worker
        case workerName = "workerName"
        case projectId = "projectId"
        case siteId = "siteId"
        case date
        case status
        case checkIn = "checkIn"             
        case checkOut = "checkOut"
    }
}

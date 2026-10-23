import Foundation
import FirebaseFirestore

// MARK: - Attendance Status Enum
enum AttendanceStatus: String, Codable, CaseIterable, Identifiable {
    case present = "Present"
    case late = "Late"
    case absent = "Absent"
    
    var id: String { rawValue }
}

// MARK: - Attendance Collection ("attendance")
struct AttendanceRecord: Identifiable, Codable {
    @DocumentID var id: String?
    var worker: String
    var workerName: String
    var projectId: String
    var siteId: String
    var date: Date
    var status: AttendanceStatus
    var checkIn: Timestamp?
    var checkOut: Timestamp?
    
    enum CodingKeys: String, CodingKey {
        case id
        case worker
        case workerName = "workername"
        case projectId = "projectid"
        case siteId = "siteid"
        case date
        case status
        case checkIn = "checkin"
        case checkOut = "checkout"
    }
}

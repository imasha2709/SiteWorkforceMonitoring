import Foundation

struct Attendance: Identifiable {
    var id: String
    var workerId: String
    var workerName: String
    var projectId: String
    var siteId: String
    var date: String
    var status: String
    var checkIn: String
    var checkOut: String
}
import Foundation
import FirebaseFirestore
import SwiftUI

struct WorkerModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var role: String
    var siteId: String
    var status: AttendanceStatus
    
    var site: String { siteId }
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: name) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        let letters = name.split(separator: " ").compactMap { $0.first }
        let first = letters.first.map(String.init) ?? ""
        let last = letters.dropFirst().first.map(String.init) ?? ""
        return (first + last).uppercased()
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case role
        case siteId = "siteid"
        case status
    }
}

typealias Worker = WorkerModel

import Foundation

struct AppUser: Identifiable, Codable {
    let id: String
    var email: String
    var name: String
    var role: UserRole
    var assignedSite: String?
    
    init(id: String = UUID().uuidString, email: String, name: String, role: UserRole, assignedSite: String? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.role = role
        self.assignedSite = assignedSite
    }
}


import Foundation

struct AppUser: Identifiable {
    let id: String
    let name: String
    let email: String
    let role: UserRole
    let assignedSite: String?
}

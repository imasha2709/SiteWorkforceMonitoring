
import Foundation
import Combine

final class AuthenticationViewModel: ObservableObject {
    @Published private(set) var currentUser: AppUser?

    var isSignedIn: Bool {
        currentUser != nil
    }

    func signInAsDemoUser(_ role: UserRole) {
        currentUser = AppUser(
            id: "demo-user-001",
            name: "Demo User",
            email: "demo@example.com",
            role: role,
            assignedSite: role == .siteWorker
                ? "Colombo Tower"
                : nil
        )
    }

    func signOut() {
        currentUser = nil
    }
}

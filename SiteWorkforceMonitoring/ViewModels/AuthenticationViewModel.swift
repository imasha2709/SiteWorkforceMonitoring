import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class AuthenticationViewModel: ObservableObject {
    @Published var hasCompletedOnboarding = false
    @Published var isSignedIn = false
    @Published var currentUser: AppUser? = nil

    private let db = Firestore.firestore()

    init() {
        try? Auth.auth().signOut()
    }

    func completeOnboarding() {
        self.hasCompletedOnboarding = true
    }
    
    // MARK: - Update User Profile
    func updateUserProfile(name: String, assignedSite: String?, completion: @escaping (String?) -> Void) {
        guard let uid = currentUser?.id else {
            completion("No active user found.")
            return
        }
        
        var updatedData: [String: Any] = [
            "name": name
        ]
        
        if let site = assignedSite {
            updatedData["assignedSite"] = site
        } else {
            updatedData["assignedSite"] = NSNull()
        }
        
        db.collection("users").document(uid).updateData(updatedData) { [weak self] error in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    self?.currentUser?.name = name
                    self?.currentUser?.assignedSite = assignedSite
                    completion(nil)
                }
            }
        }
    }

    func signIn(email: String, password: String, completion: @escaping (String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(error.localizedDescription)
                return
            }
            
            if let uid = result?.user.uid {
                self?.fetchUserProfile(uid: uid) { fetchError in
                    completion(fetchError)
                }
            } else {
                completion("User ID not found.")
            }
        }
    }
    
    func signUp(email: String, password: String, name: String, role: UserRole, completion: @escaping (String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                completion(error.localizedDescription)
                return
            }
            
            guard let uid = result?.user.uid else {
                completion("Failed to create user account.")
                return
            }
            
            let newUser = AppUser(id: uid, email: email, name: name, role: role)
            
            do {
                try self?.db.collection("users").document(uid).setData(from: newUser) { error in
                    if let error = error {
                        completion(error.localizedDescription)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self?.currentUser = newUser
                        self?.isSignedIn = true
                        completion(nil)
                    }
                }
            } catch {
                completion(error.localizedDescription)
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (String) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(error.localizedDescription)
            } else {
                completion("Password reset email sent successfully. Please check your inbox.")
            }
        }
    }
    
    private func fetchUserProfile(uid: String, completion: ((String?) -> Void)? = nil) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            if let error = error {
                completion?(error.localizedDescription)
                return
            }
            
            if let user = try? snapshot?.data(as: AppUser.self) {
                DispatchQueue.main.async {
                    self?.currentUser = user
                    self?.isSignedIn = true
                    completion?(nil)
                }
            } else {
                DispatchQueue.main.async {
                    self?.isSignedIn = true
                    completion?(nil)
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.isSignedIn = false
                self.currentUser = nil
                self.hasCompletedOnboarding = false
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

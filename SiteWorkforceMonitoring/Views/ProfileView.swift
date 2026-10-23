import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authentication: AuthenticationViewModel
    
    @AppStorage("appTheme") private var appTheme: String = "system"

    @State private var editedName = ""
    @State private var editedSite = ""
    @State private var showSaveAlert = false
    @State private var alertMessage = ""

    var body: some View {
        List {
            // Profile Header Summary
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.orange)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(authentication.currentUser?.name ?? "Project Manager")
                            .font(.title3.bold())
                        Text(authentication.currentUser?.email ?? "")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }

            // Editable Profile Fields
            Section("Edit Information") {
                HStack {
                    Text("Full Name")
                        .foregroundStyle(.secondary)
                        .frame(width: 100, alignment: .leading)
                    TextField("Full Name", text: $editedName)
                }

                HStack {
                    Text("Assigned Site")
                        .foregroundStyle(.secondary)
                        .frame(width: 100, alignment: .leading)
                    TextField("Assigned Site", text: $editedSite)
                }

                Button {
                    saveProfileChanges()
                } label: {
                    HStack {
                        Spacer()
                        Text("Save Changes")
                            .font(.headline)
                        Spacer()
                    }
                }
                .foregroundStyle(.orange)
            }

            // Role & Access Details
            Section("Role & Access") {
                HStack {
                    Label("Access Level", systemImage: "shield.fill")
                    Spacer()
                    Text(authentication.currentUser?.role.rawValue ?? "Project Manager")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Label("Email Address", systemImage: "envelope.fill")
                    Spacer()
                    Text(authentication.currentUser?.email ?? "")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            editedName = authentication.currentUser?.name ?? ""
            editedSite = authentication.currentUser?.assignedSite ?? ""
        }
        .alert("Notice", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .preferredColorScheme(getColorScheme())
    }

    private func saveProfileChanges() {
        guard !editedName.isEmpty else {
            alertMessage = "Name cannot be empty."
            showSaveAlert = true
            return
        }

        authentication.updateUserProfile(name: editedName, assignedSite: editedSite.isEmpty ? nil : editedSite) { error in
            if let error = error {
                alertMessage = "Failed to update profile: \(error)"
            } else {
                alertMessage = "Profile updated successfully!"
            }
            showSaveAlert = true
        }
    }

    private func getColorScheme() -> ColorScheme? {
        switch appTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}

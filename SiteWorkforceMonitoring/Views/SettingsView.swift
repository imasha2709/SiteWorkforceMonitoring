import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authentication: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("appTheme") private var appTheme: String = "system"
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    
    @State private var showSignOutConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        ProfileView()
                            .environmentObject(authentication)
                    } label: {
                        HStack(spacing: 16) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.orange)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(authentication.currentUser?.name ?? "Project Manager")
                                    .font(.headline)
                                Text(authentication.currentUser?.email ?? "manager@workforce.com")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Account")
                } footer: {
                    Text("Tap to view and edit your profile details.")
                }

                Section("Appearance") {
                    Picker("Theme Mode", selection: $appTheme) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 4)
                }

                Section("Preferences") {
                    Toggle("Enable In-App Notifications", isOn: $notificationsEnabled)
                }

                Section("About App") {
                    HStack {
                        Text("Role")
                        Spacer()
                        Text(authentication.currentUser?.role.rawValue ?? "Project Manager")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showSignOutConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                                .font(.headline)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Sign Out", isPresented: $showSignOutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    authentication.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out of your account?")
            }
        }
        .preferredColorScheme(getColorScheme())
    }

    private func getColorScheme() -> ColorScheme? {
        switch appTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}

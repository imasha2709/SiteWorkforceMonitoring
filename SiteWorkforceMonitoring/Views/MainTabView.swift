import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authentication: AuthenticationViewModel
    @State private var showingSettings = false

    var body: some View {
        Group {
            if authentication.isSignedIn {
                if let user = authentication.currentUser {
                    TabView {
                        DashboardView()
                            .tabItem {
                                Label("Dashboard", systemImage: "house.fill")
                            }

                        WorkersView()
                            .tabItem {
                                Label("Workers", systemImage: "person.3.fill")
                            }

                        AttendanceView()
                            .tabItem {
                                Label("Attendance", systemImage: "calendar")
                            }

                        ProjectsView()
                            .tabItem {
                                Label("Projects", systemImage: "building.2.fill")
                            }

                        SiteMapView()
                            .tabItem {
                                Label("Site Map", systemImage: "map.fill")
                            }
                    }
                    .overlay(alignment: .topTrailing) {
                        Button {
                            showingSettings.toggle()
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundStyle(.orange)
                                .padding()
                        }
                    }
                    .sheet(isPresented: $showingSettings) {
                        SettingsView()
                            .environmentObject(authentication)
                    }
                } else {
                    ProgressView("Loading user profile...")
                }
            } else {
                LoginView()
            }
        }
        .tint(.orange)
    }
}

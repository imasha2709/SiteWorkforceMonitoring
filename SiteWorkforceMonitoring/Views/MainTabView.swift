
import SwiftUI

struct MainTabView: View {
    @StateObject private var authentication =
        AuthenticationViewModel()

    var body: some View {
        Group {
            if authentication.isSignedIn {
                if let user = authentication.currentUser {
                    TabView {
                        DashboardView()
                            .tabItem {
                                Label("Dashboard", systemImage: "house.fill")
                            }

                        if user.role.canViewWorkers {
                            WorkersView()
                                .tabItem {
                                    Label("Workers", systemImage: "person.3.fill")
                                }
                        }

                        AttendanceView()
                            .tabItem {
                                Label("Attendance", systemImage: "calendar")
                            }

                        if user.role.canViewAllProjects ||
                            user.role == .siteSupervisor {
                            ProjectsView()
                                .tabItem {
                                    Label("Projects", systemImage: "building.2.fill")
                                }
                        }

                        SiteMapView()
                            .tabItem {
                                Label("Site Map", systemImage: "map.fill")
                            }
                    }
                    .overlay(alignment: .topTrailing) {
                        Menu {
                            Text(user.name)
                            Text(user.role.rawValue)

                            Button("Sign Out", role: .destructive) {
                                authentication.signOut()
                            }
                        } label: {
                            Image(systemName: "person.crop.circle")
                                .font(.title2)
                                .foregroundStyle(.orange)
                                .padding()
                        }
                    }
                }
            } else {
                LoginView()
            }
        }
        .environmentObject(authentication)
        .tint(.orange)
    }
}

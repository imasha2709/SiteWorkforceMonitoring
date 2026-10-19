import SwiftUI
struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2.fill")
                }
WorkersView()
                .tabItem {
                    Label("Workers", systemImage: "person.2.fill")
                }
AttendanceView()
                .tabItem {
                    Label("Attendance", systemImage: "checkmark.circle.fill")
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
        .tint(AppTheme.orange)
    }
}

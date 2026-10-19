import SwiftUI

@main
struct SiteWorkforceMonitoringApp: App {
    @StateObject private var authVM = AuthenticationViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isSignedIn {
                    SplashView() // Transitions into your MainTabView dashboard
                        .environmentObject(authVM)
                } else {
                    LoginView()
                        .environmentObject(authVM)
                }
            }
        }
    }
}

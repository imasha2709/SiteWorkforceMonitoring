import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct SiteWorkforceMonitoringApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authVM = AuthenticationViewModel()
    

    @AppStorage("appTheme") private var appTheme: String = "system"

    var body: some Scene {
        WindowGroup {
            Group {
                if !authVM.hasCompletedOnboarding {
                    OnboardingView(onFinish: {
                        authVM.completeOnboarding()
                    })
                    .environmentObject(authVM)
                } else if !authVM.isSignedIn {
                    LoginView()
                        .environmentObject(authVM)
                } else {
                    MainTabView()
                        .environmentObject(authVM)
                }
            }
          
            .preferredColorScheme(getColorScheme())
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

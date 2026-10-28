import SwiftUI
import FirebaseCore
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
   
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
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

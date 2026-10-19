import SwiftUI

struct SiteWorkforceMonitoringAppView: View {
    
    @StateObject private var authentication = AuthenticationViewModel()
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    
    
    @State private var showSplash = true

    var body: some View {
        Group {
            if showSplash {
                SplashView()
                    .transition(.opacity)
            } else if authentication.isSignedIn {
                
                Text("Main App Dashboard")
                    .environmentObject(authentication)
            } else {
                LoginView()
                    .environmentObject(authentication)
            }
        }
        .onAppear {
          
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}

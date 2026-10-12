
import SwiftUI

struct AppStartView: View {
    @AppStorage("hasCompletedOnboarding")
    private var hasCompletedOnboarding = false

    @State private var showSplash = true

    var body: some View {
        Group {
            if showSplash {
                SplashView()
            } else if !hasCompletedOnboarding {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            } 
        }
        .task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)

            withAnimation {
                showSplash = false
            }
        }
    }
}

#Preview {
    AppStartView()
}

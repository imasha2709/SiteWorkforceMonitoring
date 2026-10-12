
import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.orange
                .ignoresSafeArea()

            VStack(spacing: 22) {
                Image(systemName: "building.2.crop.circle.fill")
                    .font(.system(size: 88))
                    .foregroundStyle(.white)

                Text("SITE WORKFORCE")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("PROJECT MONITORING")
                    .font(.system(size: 16, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.9))

                ProgressView()
                    .tint(.white)
                    .padding(.top, 20)
            }
            .padding(24)
        }
    }
}

#Preview {
    SplashView()
}

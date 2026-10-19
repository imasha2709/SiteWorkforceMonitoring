import SwiftUI

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
           
            MainTabView()
        } else {
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
            .onAppear {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}

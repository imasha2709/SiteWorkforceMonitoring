import SwiftUI

enum AppTheme {
    static let orange = Color(red: 0.96, green: 0.38, blue: 0.12)
    static let orangeLight = Color(red: 1.00, green: 0.93, blue: 0.88)
    
    static let maroon = Color(red: 0.48, green: 0.12, blue: 0.14)
    static let maroonBrown = Color(red: 0.38, green: 0.16, blue: 0.15)
    
    static let progressGradient = LinearGradient(
        colors: [Color(red: 0.96, green: 0.38, blue: 0.12), Color(red: 0.48, green: 0.12, blue: 0.14)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let ink = Color(red: 0.13, green: 0.16, blue: 0.20)
    static let secondary = Color(red: 0.43, green: 0.47, blue: 0.52)
    static let background = Color(red: 0.97, green: 0.97, blue: 0.96)
    static let green = Color(red: 0.12, green: 0.57, blue: 0.36)
    static let red = Color(red: 0.78, green: 0.22, blue: 0.19)
    static let blue = Color(red: 0.20, green: 0.42, blue: 0.78)
}

struct GradientProgressView: View {
    var progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(AppTheme.secondary.opacity(0.15))
                    .frame(height: 8)
                    .clipShape(Capsule())

                Rectangle()
                    .fill(AppTheme.progressGradient)
                    .frame(width: max(geometry.size.width * CGFloat(min(max(progress, 0), 1)), 0), height: 8)
                    .clipShape(Capsule())
            }
        }
        .frame(height: 8)
    }
}

struct SurfaceCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        }
    }
}

struct SectionHeading: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(AppTheme.ink)
    }
}

struct StatusPill: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.11))
            .clipShape(Capsule())
    }
}

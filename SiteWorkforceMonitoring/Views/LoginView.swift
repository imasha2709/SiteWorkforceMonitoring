
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authentication: AuthenticationViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "building.2.crop.circle.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.orange)

                Text("Site Workforce")
                    .font(.largeTitle.bold())

                Text("Select a demo role")
                    .foregroundStyle(.secondary)

                ForEach(UserRole.allCases) { role in
                    Button {
                        authentication.signInAsDemoUser(role)
                    } label: {
                        HStack {
                            Text(role.rawValue)
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .padding()
                        .foregroundStyle(.white)
                        .background(.orange)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12)
                        )
                    }
                    .buttonStyle(.plain)
                }

                Text("Demo mode only — no real authentication")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: 450)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

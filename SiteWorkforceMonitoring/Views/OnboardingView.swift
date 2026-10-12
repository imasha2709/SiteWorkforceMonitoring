
import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()

    let onFinish: () -> Void

    private let orange = Color.orange

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                HStack {
                    Text("SITE WORKFORCE")
                        .font(.caption.weight(.bold))
                        .tracking(1)
                        .foregroundStyle(orange)

                    Spacer()

                    Button("Skip") {
                        onFinish()
                    }
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                TabView(selection: $viewModel.currentPage) {
                    ForEach(Array(viewModel.pages.enumerated()), id: \.offset) { index, page in
                        VStack(spacing: 26) {
                            Spacer()

                            Image(systemName: page.icon)
                                .font(.system(size: min(geometry.size.width * 0.22, 100)))
                                .foregroundStyle(orange)
                                .frame(width: 190, height: 190)
                                .background(orange.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 36))

                            Text(page.title)
                                .font(.system(size: 27, weight: .bold))
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.8)

                            Text(page.subtitle)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(5)
                                .frame(maxWidth: 430)

                            Spacer()
                            Spacer()
                        }
                        .padding(.horizontal, 28)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                HStack(spacing: 8) {
                    ForEach(0..<viewModel.pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == viewModel.currentPage
                                  ? orange
                                  : orange.opacity(0.25))
                            .frame(
                                width: index == viewModel.currentPage ? 25 : 8,
                                height: 8
                            )
                    }
                }

                Button {
                    if viewModel.isLastPage {
                        onFinish()
                    } else {
                        withAnimation {
                            viewModel.nextPage()
                        }
                    }
                } label: {
                    Text(viewModel.isLastPage ? "Get Started" : "Next")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(orange)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .frame(maxWidth: 700)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    OnboardingView(onFinish: {})
}

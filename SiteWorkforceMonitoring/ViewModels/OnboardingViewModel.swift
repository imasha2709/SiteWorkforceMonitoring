
import Foundation
import Combine

final class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Manage Your Workforce",
            subtitle: "View workers, monitor attendance, and keep your construction team organised.",
            icon: "person.3.fill"
        ),
        OnboardingPage(
            title: "Monitor Construction Sites",
            subtitle: "Explore project locations, check project progress, and review site information.",
            icon: "map.fill"
        ),
        OnboardingPage(
            title: "Stay Informed",
            subtitle: "Access important workforce and project information from one convenient app.",
            icon: "bell.badge.fill"
        )
    ]

    var isLastPage: Bool {
        currentPage == pages.count - 1
    }

    func nextPage() {
        if currentPage < pages.count - 1 {
            currentPage += 1
        }
    }

    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
}

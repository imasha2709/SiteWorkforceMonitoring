
import Foundation
import Combine

final class ProjectsViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedStatus = "All"

    let projects = SampleData.projects

    let statusOptions = [
        "All",
        "On track",
        "Attention"
    ]

    var filteredProjects: [ConstructionProject] {
        projects.filter { project in
            let matchesSearch =
                searchText.isEmpty ||
                project.name.localizedCaseInsensitiveContains(searchText) ||
                project.location.localizedCaseInsensitiveContains(searchText)

            let matchesStatus =
                selectedStatus == "All" ||
                project.status == selectedStatus

            return matchesSearch && matchesStatus
        }
    }

    var totalWorkersAssigned: Int {
        projects.reduce(0) { $0 + $1.workersAssigned }
    }

    var averageProgress: Double {
        guard !projects.isEmpty else { return 0 }

        return projects.reduce(0) {
            $0 + $1.progress
        } / Double(projects.count)
    }

    var projectsNeedingAttention: Int {
        projects.filter { $0.status == "Attention" }.count
    }
}

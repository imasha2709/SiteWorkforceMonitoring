import Foundation
import Combine
import CoreLocation

final class ProjectsViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedStatus = "All"
    @Published var projects = SampleData.projects

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

    func addProject(name: String, location: String, description: String, imageName: String, workersAssigned: Int, latitude: Double, longitude: Double) {
        let newProject = ConstructionProject(
            name: name,
            location: location,
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            progress: 0.0,
            status: "On track",
            workersAssigned: workersAssigned,
            imageName: imageName.isEmpty ? "building.2.fill" : imageName,
            description: description,
            tasks: []
        )
        projects.append(newProject)
    }
}

import Foundation
import Combine

final class SiteMapViewModel: ObservableObject {
    @Published var selectedProjectName: String? =
        SampleData.projects.first?.name

    @Published var searchText = ""
    @Published var selectedStatus = "All"

    let projects = SampleData.projects
    let attendance = SampleData.attendance

    let statusOptions = ["All", "Present", "Late", "Absent"]

    var selectedProject: ConstructionProject? {
        projects.first {
            $0.name == selectedProjectName
        }
    }

    var filteredAttendance: [AttendanceRecord] {
        attendance.filter { record in
            let matchesSearch =
                searchText.isEmpty ||
                record.workerName.localizedCaseInsensitiveContains(searchText) ||
                record.site.localizedCaseInsensitiveContains(searchText)

            let matchesStatus =
                selectedStatus == "All" ||
                record.status.rawValue == selectedStatus

            let matchesProject =
                selectedProjectName == nil ||
                record.site == selectedProjectName

            return matchesSearch && matchesStatus && matchesProject
        }
    }

    // Fixed: Changed WorkerStatus to AttendanceStatus
    func count(for status: AttendanceStatus) -> Int {
        attendance.filter { record in
            record.status == status &&
            (selectedProjectName == nil ||
             record.site == selectedProjectName)
        }.count
    }
}

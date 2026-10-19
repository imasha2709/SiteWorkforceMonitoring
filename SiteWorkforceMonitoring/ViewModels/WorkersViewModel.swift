import Foundation
import Combine

@MainActor
final class WorkersViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedStatus = "All"

    let workers = SampleData.workers

    let statusOptions = [
        "All", "Present", "Late", "Absent"
    ]

    var filteredWorkers: [Worker] {
        workers.filter { worker in
            let matchesSearch =
                searchText.isEmpty ||
                worker.name.localizedCaseInsensitiveContains(searchText) ||
                worker.role.localizedCaseInsensitiveContains(searchText) ||
                worker.site.localizedCaseInsensitiveContains(searchText)

            let matchesStatus =
                selectedStatus == "All" ||
                worker.status.rawValue == selectedStatus

            return matchesSearch && matchesStatus
        }
    }

    
    func count(for status: AttendanceStatus) -> Int {
        workers.filter { $0.status == status }.count
    }
}

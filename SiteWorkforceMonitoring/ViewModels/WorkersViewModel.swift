import Foundation
import Combine

@MainActor
final class WorkersViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedStatus = "All"
    @Published var workers = SampleData.workers

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

    func addWorker(name: String, role: String, site: String) {
        let initials = name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map { String($0).uppercased() }
            .joined()

        let newWorker = Worker(
            name: name,
            role: role,
            site: site,
            status: .present,
            initials: initials.isEmpty ? "WK" : initials
        )
        workers.append(newWorker)
    }
}

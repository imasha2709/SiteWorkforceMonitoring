import Foundation
import Combine

@MainActor
final class AttendanceViewModel: ObservableObject {
    @Published var records = SampleData.attendance
    @Published var searchText = ""
    @Published var selectedStatus = "All"

    let statusOptions = ["All", "Present", "Late", "Absent"]

    var filteredRecords: [AttendanceRecord] {
        records.filter { record in
            let matchesSearch =
                searchText.isEmpty ||
                record.workerName.localizedCaseInsensitiveContains(searchText) ||
                record.site.localizedCaseInsensitiveContains(searchText)

            let matchesStatus =
                selectedStatus == "All" ||
                record.status.rawValue == selectedStatus

            return matchesSearch && matchesStatus
        }
    }

    var presentCount: Int {
        records.filter { $0.status == .present }.count
    }

    var lateCount: Int {
        records.filter { $0.status == .late }.count
    }

    var absentCount: Int {
        records.filter { $0.status == .absent }.count
    }
}

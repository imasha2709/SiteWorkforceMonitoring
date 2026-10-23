import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
final class SiteMapViewModel: ObservableObject {
    @Published var projects: [ConstructionProject] = []
    @Published var attendance: [AttendanceRecord] = []
    @Published var selectedProjectName: String? = nil
    @Published var searchText = ""
    @Published var selectedStatus = "All"

    let statusOptions = ["All", "Present", "Late", "Absent"]
    
    private let db = Firestore.firestore()
    private var projectsListener: ListenerRegistration?
    private var attendanceListener: ListenerRegistration?

    init() {
        fetchProjects()
        fetchAttendance()
    }

    deinit {
        projectsListener?.remove()
        attendanceListener?.remove()
    }

    func fetchProjects() {
        projectsListener = db.collection("projects").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents else { return }
            self.projects = documents.compactMap { doc in
                try? doc.data(as: ConstructionProject.self)
            }
        }
    }

    func fetchAttendance() {
        attendanceListener = db.collection("attendance").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents else { return }
            self.attendance = documents.compactMap { doc in
                try? doc.data(as: AttendanceRecord.self)
            }
        }
    }

    var selectedProject: ConstructionProject? {
        projects.first { $0.name == selectedProjectName }
    }

    var filteredAttendance: [AttendanceRecord] {
        attendance.filter { record in
            let matchesSearch = searchText.isEmpty ||
                record.workerName.localizedCaseInsensitiveContains(searchText) ||
                record.siteId.localizedCaseInsensitiveContains(searchText)

            let matchesStatus = selectedStatus == "All" || record.status.rawValue == selectedStatus
            let matchesProject = selectedProjectName == nil || record.siteId == selectedProjectName

            return matchesSearch && matchesStatus && matchesProject
        }
    }

    func count(for status: AttendanceStatus) -> Int {
        attendance.filter { record in
            record.status == status &&
            (selectedProjectName == nil || record.siteId == selectedProjectName)
        }.count
    }
}

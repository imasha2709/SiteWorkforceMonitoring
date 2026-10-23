import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
class AttendanceViewModel: ObservableObject {
    @Published var attendanceRecords: [AttendanceRecord] = []
    @Published var searchText: String = ""
    @Published var selectedStatus: AttendanceStatus? = nil
    
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        fetchAttendance()
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func fetchAttendance() {
        listenerRegistration = db.collection("attendance")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                
                self.attendanceRecords = documents.compactMap { doc in
                    try? doc.data(as: AttendanceRecord.self)
                }
            }
    }
    
    var filteredRecords: [AttendanceRecord] {
        attendanceRecords.filter { record in
            let matchesSearch = searchText.isEmpty ||
                record.workerName.localizedCaseInsensitiveContains(searchText) ||
                record.siteId.localizedCaseInsensitiveContains(searchText)
            
            let matchesStatus = selectedStatus == nil || record.status == selectedStatus
            return matchesSearch && matchesStatus
        }
    }
    
    func updateStatus(for recordId: String, newStatus: AttendanceStatus) {
        db.collection("attendance").document(recordId).updateData([
            "status": newStatus.rawValue
        ])
    }
}

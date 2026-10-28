import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
class WorkersViewModel: ObservableObject {
    @Published var workers: [Worker] = []
    @Published var attendanceRecords: [AttendanceRecord] = []
    @Published var searchText: String = ""
    @Published var selectedStatus: String = "All"
    
    let statusOptions = ["All", "Present", "Late", "Absent"]
    let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        fetchAttendanceForToday()
        fetchAttendanceRecords()
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func fetchAttendanceForToday() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
         
        listenerRegistration = db.collection("attendance")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                 
                self.workers = documents.compactMap { doc -> Worker? in
                    let data = doc.data()
                    let id = doc.documentID
                    let name = data["workername"] as? String ?? "Unknown Worker"
                    let role = data["role"] as? String ?? "Laborer"
                    let site = data["siteid"] as? String ?? "General Site"
                    let rawStatus = data["status"] as? String ?? "Absent"
                    let status = AttendanceStatus(rawValue: rawStatus) ?? .absent
                     
              
                    return Worker(id: id, name: name, role: role, siteId: site, status: status)
                }
            }
    }

    func fetchAttendanceRecords() {
        db.collection("attendance").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents else { return }
             
            self.attendanceRecords = documents.compactMap { doc -> AttendanceRecord? in
                let data = doc.data()
                let id = doc.documentID
                let workerName = data["workername"] as? String ?? ""
                let siteId = data["siteid"] as? String ?? ""
                 
                let recordDate = (data["date"] as? Timestamp)?.dateValue() ?? Date()
                 
                let checkInTimestamp = data["checkin"] as? Timestamp ?? Timestamp(date: Date())
                 
                let rawStatus = data["status"] as? String ?? "Absent"
                let status = AttendanceStatus(rawValue: rawStatus) ?? .absent
                let workerId = data["worker"] as? String ?? ""
                let projectId = data["projectId"] as? String ?? ""
                 
                return AttendanceRecord(
                    id: id,
                    worker: workerId,
                    workerName: workerName,
                    projectId: projectId,
                    siteId: siteId,
                    date: recordDate,
                    status: status,
                    checkIn: checkInTimestamp
                )
            }
        }
    }

    func addWorker(name: String, role: String, siteId: String, status: AttendanceStatus) {
        let workerId = UUID().uuidString
        let currentDate = Date()
         
        let newAttendance: [String: Any] = [
            "worker": workerId,
            "projectId": "default_project",
            "siteid": siteId,
            "workername": name,
            "role": role,
            "status": status.rawValue,
            "date": Timestamp(date: currentDate),
            "checkin": Timestamp(date: currentDate)
        ]
         
        db.collection("attendance").addDocument(data: newAttendance) { error in
            if let error = error {
                print("Error adding worker attendance: \(error.localizedDescription)")
            }
        }
    }

    func recordsForWorker(_ workerName: String) -> [AttendanceRecord] {
        return attendanceRecords.filter { $0.workerName.localizedCaseInsensitiveCompare(workerName) == .orderedSame }
    }

    var filteredWorkers: [Worker] {
        workers.filter { worker in
            let matchesSearch = searchText.isEmpty ||
                worker.name.localizedCaseInsensitiveContains(searchText) ||
                worker.site.localizedCaseInsensitiveContains(searchText) ||
                worker.role.localizedCaseInsensitiveContains(searchText)
             
            let matchesStatus = selectedStatus == "All" || worker.status.rawValue == selectedStatus
            return matchesSearch && matchesStatus
        }
    }
    
    func count(for status: AttendanceStatus) -> Int {
        workers.filter { $0.status == status }.count
    }
    
    func updateStatus(for workerId: String, newStatus: AttendanceStatus) {
        db.collection("attendance").document(workerId).updateData([
            "status": newStatus.rawValue
        ])
    }
}

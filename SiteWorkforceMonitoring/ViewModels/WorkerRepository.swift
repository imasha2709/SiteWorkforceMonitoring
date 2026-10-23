import Foundation
import FirebaseFirestore

final class WorkerRepository {
    private let db = Firestore.firestore()

    func fetchWorkers() async throws -> [WorkerModel] {
        let snapshot = try await db.collection("workers").getDocuments()
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: WorkerModel.self)
        }
    }

    func addWorker(name: String, role: String, siteId: String, status: String) async throws {
        let docRef = db.collection("workers").document()
        let attendanceStatus = AttendanceStatus(rawValue: status) ?? .present
        
        let worker = WorkerModel(
            id: docRef.documentID,
            name: name,
            role: role,
            siteId: siteId,
            status: attendanceStatus
        )
        try docRef.setData(from: worker)
    }
}

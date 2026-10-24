import Foundation
import FirebaseFirestore
import Combine

@MainActor
class TasksViewModel: ObservableObject {
    @Published var tasks: [ProjectTask] = []
    let db = Firestore.firestore()
    
    func fetchTasks(for projectId: String) {
        db.collection("tasks")
            .whereField("projectId", isEqualTo: projectId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self?.tasks = documents.compactMap { doc -> ProjectTask? in
                    try? doc.data(as: ProjectTask.self)
                }
            }
    }
    
    func toggleTaskCompletion(task: ProjectTask) {
        guard let id = task.id else { return }
        let newStatus = !task.isCompleted
        db.collection("tasks").document(id).updateData([
            "completes": newStatus
        ])
    }
}

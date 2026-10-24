import Foundation
import FirebaseFirestore

final class ProjectRepository {
    private let db = Firestore.firestore()

    func fetchProjects() async throws -> [ConstructionProject] {
        let snapshot = try await db
            .collection("projects")
            .getDocuments()

        return snapshot.documents.compactMap { document in
            try? document.data(as: ConstructionProject.self)
        }
    }
}

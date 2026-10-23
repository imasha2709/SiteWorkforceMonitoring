import Foundation
import FirebaseFirestore

final class ProjectRepository {
    private let db = Firestore.firestore()

    func fetchProjects() async throws -> [ConstructionProject] {
        let snapshot = try await db
            .collection("projects")
            .getDocuments()

        return snapshot.documents.compactMap { document in
            let data = document.data()

            guard
                let projectId = data["projectId"] as? String,
                let name = data["name"] as? String,
                let location = data["location"] as? String,
                let progress = data["progress"] as? NSNumber,
                let status = data["status"] as? String,
                let managerName = data["managerName"] as? String
            else {
                return nil
            }

            return ConstructionProject(
                id: document.documentID,
                projectId: projectId,
                name: name,
                location: location,
                progress: progress.doubleValue,
                status: status,
                managerName: managerName
            )
        }
    }
}
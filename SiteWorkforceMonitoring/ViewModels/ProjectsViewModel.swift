import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
class ProjectsViewModel: ObservableObject {
    @Published var projects: [ConstructionProject] = []
    @Published var searchText: String = ""
    @Published var selectedStatus: String = "All"
    
    let statusOptions = ["All", "On track", "Attention", "Delayed", "Completed"]
    let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        fetchProjects()
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func fetchProjects() {
        listenerRegistration = db.collection("projects").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents else { return }
            
            self.projects = documents.compactMap { doc -> ConstructionProject? in
                let data = doc.data()
                let id = doc.documentID
                let projectId = data["projectId"] as? String ?? id
                let name = data["name"] as? String ?? ""
                let location = data["location"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let status = data["status"] as? String ?? "On track"
                let managerName = data["managerName"] as? String ?? "Site Manager"
                let imageName = data["imageName"] as? String ?? "building.2.fill"
                let startDate = data["startDate"] as? String ?? "N/A"
                let completionDate = data["expectedCompletionDate"] as? String ?? "N/A"
                let workersAssigned = data["workersAssigned"] as? Int ?? 0
                let progress = data["progress"] as? Double ?? 0.0
                let lat = data["latitude"] as? Double ?? 6.9271
                let lon = data["longitude"] as? Double ?? 79.8612
                
                return ConstructionProject(
                    id: id,
                    projectId: projectId,
                    name: name,
                    location: location,
                    progress: progress,
                    status: status,
                    managerName: managerName
                )
            }
        }
    }

    func addProject(name: String, location: String, description: String, status: String, startDate: String, completionDate: String, workersCount: Int, latitude: Double, longitude: Double) {
        let newProject: [String: Any] = [
            "projectId": UUID().uuidString,
            "name": name,
            "location": location,
            "description": description,
            "status": status,
            "startDate": startDate,
            "expectedCompletionDate": completionDate,
            "workersAssigned": workersCount,
            "progress": 0.0,
            "latitude": latitude,
            "longitude": longitude,
            "managerName": "Site Manager",
            "imageName": "building.2.fill"
        ]
        
        db.collection("projects").addDocument(data: newProject) { error in
            if let error = error {
                print("Error adding project: \(error.localizedDescription)")
            }
        }
    }

    var filteredProjects: [ConstructionProject] {
        projects.filter { project in
            let matchesSearch = searchText.isEmpty ||
                project.name.localizedCaseInsensitiveContains(searchText) ||
                project.location.localizedCaseInsensitiveContains(searchText)
            let matchesStatus = selectedStatus == "All" || project.status == selectedStatus
            return matchesSearch && matchesStatus
        }
    }

    var averageProgress: Double {
        guard !projects.isEmpty else { return 0.0 }
        let total = projects.reduce(0.0) { $0 + $1.progress }
        return total / Double(projects.count)
    }

    var totalWorkersAssigned: Int {
        projects.reduce(0) { $0 + ($1.workersAssigned ?? 0) }
    }

    var projectsNeedingAttention: Int {
        projects.filter { $0.status == "Attention" || $0.status == "Delayed" }.count
    }

    func toggleTaskCompletion(for projectId: String, taskID: String) {}
}

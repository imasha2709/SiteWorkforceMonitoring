import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
class ProjectsViewModel: ObservableObject {
    @Published var projects: [ConstructionProject] = []
    @Published var projectTasks: [ProjectTask] = []
    @Published var searchText: String = ""
    @Published var selectedStatus: String = "All"
    
    let statusOptions = ["All", "On track", "Attention", "Delayed", "Completed"]
    let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var tasksListenerRegistration: ListenerRegistration?
    
    init() {
        fetchProjects()
    }
    
    deinit {
        listenerRegistration?.remove()
        tasksListenerRegistration?.remove()
    }
    
    func fetchProjects() {
        listenerRegistration = db.collection("projects").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents else { return }
            
            self.projects = documents.compactMap { doc -> ConstructionProject? in
                let data = doc.data()
                let id = doc.documentID
                let projectId = data["projectId"] as? String ?? id
                let name = data["name"] as? String ?? ""
                let location = data["location"] as? String
                let description = data["description"] as? String
                let status = data["status"] as? String ?? "On track"
                let managerName = data["managerName"] as? String ?? data["managername"] as? String ?? "Site Manager"
                let imageName = data["imageName"] as? String ?? data["imagename"] as? String
                let startDate = data["startDate"] as? String ?? data["startdate"] as? String
                let completionDate = data["expectedCompletionDate"] as? String ?? data["expectedcompletiondate"] as? String
                
                let rawProgress = data["progress"]
                let progress: Double = {
                    if let d = rawProgress as? Double {
                        return d > 1.0 ? d / 100.0 : d
                    } else if let i = rawProgress as? Int {
                        return Double(i) / 100.0
                    }
                    return 0.0
                }()
                
                let lat = data["latitude"] as? Double
                let lon = data["longitude"] as? Double
                
                var project = ConstructionProject(
                    id: id,
                    projectId: projectId,
                    name: name,
                    location: location,
                    progress: progress,
                    status: status,
                    managerName: managerName,
                    imageName: imageName,
                    description: description,
                    startDate: startDate,
                    expectedCompletionDate: completionDate,
                    workersAssigned: 0,
                    latitude: lat,
                    longitude: lon
                )
                
                self.recalculateProjectProgress(for: project)
                self.recalculateWorkerCount(for: project)
                
                return project
            }
        }
    }

    // MARK: - Update Project Status in Firestore
    func updateProjectStatus(project: ConstructionProject, newStatus: String) {
        guard let docId = project.id else { return }
        
        if let index = projects.firstIndex(where: { $0.id == docId }) {
            projects[index].status = newStatus
        }
        
        db.collection("projects").document(docId).updateData([
            "status": newStatus
        ]) { error in
            if let error = error {
                print("Error updating status: \(error.localizedDescription)")
            }
        }
    }

    private func recalculateProjectProgress(for project: ConstructionProject) {
        db.collection("tasks")
            .whereField("projectId", isEqualTo: project.projectId)
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents, !documents.isEmpty else { return }
                
                let tasks = documents.compactMap { try? $0.data(as: ProjectTask.self) }
                let completedCount = tasks.filter { $0.isCompleted }.count
                let autoProgress = Double(completedCount) / Double(tasks.count)
                
                if let index = self?.projects.firstIndex(where: { $0.projectId == project.projectId }) {
                    self?.projects[index].progress = autoProgress
                    if let docId = project.id {
                        self?.db.collection("projects").document(docId).updateData(["progress": autoProgress])
                    }
                }
            }
    }

    private func recalculateWorkerCount(for project: ConstructionProject) {
        db.collection("workers").getDocuments { [weak self] snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            let matchingWorkers = documents.filter { doc in
                let data = doc.data()
                let workerProjectId = data["projectId"] as? String ?? ""
                let workerSite = data["site"] as? String ?? ""
                
                return workerProjectId == project.projectId ||
                       workerSite.localizedCaseInsensitiveContains(project.name) ||
                       project.name.localizedCaseInsensitiveContains(workerSite)
            }
            
            let workerCount = matchingWorkers.count
            
            if let index = self?.projects.firstIndex(where: { $0.projectId == project.projectId }) {
                self?.projects[index].workersAssigned = workerCount
            }
        }
    }

    func fetchTasks(for projectId: String) {
        tasksListenerRegistration?.remove()
        tasksListenerRegistration = db.collection("tasks")
            .whereField("projectId", isEqualTo: projectId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                
                self.projectTasks = documents.compactMap { doc in
                    try? doc.data(as: ProjectTask.self)
                }
                
                let completedCount = self.projectTasks.filter { $0.isCompleted }.count
                if !self.projectTasks.isEmpty {
                    let newProgress = Double(completedCount) / Double(self.projectTasks.count)
                    
                    if let projectIndex = self.projects.firstIndex(where: { $0.projectId == projectId }) {
                        self.projects[projectIndex].progress = newProgress
                        
                        if let docId = self.projects[projectIndex].id {
                            self.db.collection("projects").document(docId).updateData(["progress": newProgress])
                        }
                    }
                }
            }
    }

    func addTask(title: String, description: String, projectId: String) {
        let newTaskData: [String: Any] = [
            "taskId": "task_\(UUID().uuidString.prefix(6))",
            "projectId": projectId,
            "title": title,
            "description": description,
            "completes": false,
            "status": "In Progress",
            "Progress": 0
        ]
        
        db.collection("tasks").addDocument(data: newTaskData) { [weak self] error in
            if error == nil {
                self?.fetchTasks(for: projectId)
            }
        }
    }

    func toggleTaskCompletion(task: ProjectTask) {
        guard let id = task.id, let projectId = task.projectId else { return }
        
        let updatedStatus = !task.isCompleted
        db.collection("tasks").document(id).updateData([
            "completes": updatedStatus,
            "status": updatedStatus ? "Completed" : "In Progress"
        ]) { [weak self] error in
            if error == nil {
                self?.fetchTasks(for: projectId)
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
        
        db.collection("projects").addDocument(data: newProject)
    }

    var filteredProjects: [ConstructionProject] {
        projects.filter { project in
            let projectLocation = project.location ?? ""
            let matchesSearch = searchText.isEmpty ||
                project.name.localizedCaseInsensitiveContains(searchText) ||
                projectLocation.localizedCaseInsensitiveContains(searchText)
            
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
}

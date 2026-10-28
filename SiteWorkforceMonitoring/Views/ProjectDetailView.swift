import SwiftUI
import MapKit
import FirebaseCore
import FirebaseFirestore

struct ProjectDetailView: View {
    let project: ConstructionProject
    @ObservedObject var viewModel: ProjectsViewModel
    
    @State private var showingSitemap = false
    @State private var showingAddTaskModal = false

    private let availableStatuses = ["On track", "Attention", "Delayed", "Completed"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                 
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(AppTheme.orange.opacity(0.15))
                        .frame(height: 200)
                        .overlay {
                            let rawImage = project.imageName ?? "building.2.fill"
                            let imageName = rawImage.isEmpty ? "building.2.fill" : rawImage
                            Image(systemName: imageName)
                                .font(.system(size: 64))
                                .foregroundStyle(AppTheme.orange)
                        }

                    LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .center, endPoint: .bottom)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(project.name)
                            .font(.title.bold())
                            .foregroundStyle(.white)
                        Text(project.location ?? "No location provided")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding()
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))

                SurfaceCard {
                    HStack {
                        Text("Project Status").font(.headline).foregroundStyle(AppTheme.ink)
                        Spacer()
                        
                      
                        Menu {
                            ForEach(availableStatuses, id: \.self) { status in
                                Button {
                                    viewModel.updateProjectStatus(project: project, newStatus: status)
                                } label: {
                                    HStack {
                                        Text(status)
                                        if project.status == status {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                StatusPill(text: project.status ?? "On track", color: statusColor(for: project.status ?? "On track"))
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                                    .foregroundStyle(AppTheme.secondary)
                            }
                        }
                    }

                    Text(project.description ?? "No description provided.")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondary)

                    Divider()

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Start Date").font(.caption).foregroundStyle(AppTheme.secondary)
                            Text(project.startDate ?? "N/A")
                                .font(.subheadline.bold())
                                .foregroundStyle(AppTheme.ink)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Expected Completion").font(.caption).foregroundStyle(AppTheme.secondary)
                            Text(project.expectedCompletionDate ?? "N/A")
                                .font(.subheadline.bold())
                                .foregroundStyle(AppTheme.ink)
                        }
                    }

                    Divider()

                    HStack {
                        Text("Overall Progress").font(.subheadline.weight(.semibold)).foregroundStyle(AppTheme.ink)
                        Spacer()
                        let progressPercentage = Int(project.progress * 100)
                        Text("\(progressPercentage)%")
                            .bold()
                            .foregroundStyle(AppTheme.maroon)
                    }

                    GradientProgressView(progress: project.progress)

                    HStack {
                        let workerCount = project.workersAssigned ?? 0
                        Text("\(workerCount) workers assigned")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondary)
                         
                        Spacer()

                        Button {
                            showingSitemap = true
                        } label: {
                            Label("View Sitemap", systemImage: "map")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppTheme.orange.opacity(0.15))
                                .foregroundStyle(AppTheme.orange)
                                .clipShape(Capsule())
                        }
                    }
                }

                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Milestones & Tasks")
                            .font(.title2.bold())
                            .foregroundStyle(AppTheme.ink)
                        Spacer()
                        Button {
                            showingAddTaskModal = true
                        } label: {
                            Label("Add Task", systemImage: "plus")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppTheme.orange)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }

                    if viewModel.projectTasks.isEmpty {
                        Text("No tasks assigned yet.")
                            .foregroundStyle(AppTheme.secondary)
                    } else {
                        ForEach(viewModel.projectTasks) { task in
                            SurfaceCard {
                                HStack(spacing: 12) {
                                    Button {
                                        viewModel.toggleTaskCompletion(task: task)
                                    } label: {
                                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                            .foregroundStyle(task.isCompleted ? AppTheme.green : AppTheme.secondary)
                                    }
                                    .buttonStyle(.plain)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(task.title)
                                            .font(.subheadline.weight(.medium))
                                            .strikethrough(task.isCompleted)
                                            .foregroundStyle(AppTheme.ink)

                                        if let desc = task.description, !desc.isEmpty {
                                            Text(desc)
                                                .font(.caption)
                                                .foregroundStyle(AppTheme.secondary)
                                        }
                                    }
                                    Spacer()
                                     
                                    if let status = task.status {
                                        StatusPill(text: status, color: task.isCompleted ? AppTheme.green : AppTheme.orange)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Project Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchTasks(for: project.projectId)
        }
        .sheet(isPresented: $showingSitemap) {
            ProjectSitemapView(project: project)
        }
        .sheet(isPresented: $showingAddTaskModal) {
            AddTaskModal(viewModel: viewModel, projectId: project.projectId)
        }
    }

    private func statusColor(for status: String) -> Color {
        switch status {
        case "Attention": return AppTheme.red
        case "Delayed": return AppTheme.red
        case "Completed": return AppTheme.blue
        default: return AppTheme.green
        }
    }
}

struct AddTaskModal: View {
    @ObservedObject var viewModel: ProjectsViewModel
    let projectId: String
    @Environment(\.dismiss) var dismiss

    @State private var taskTitle = ""
    @State private var taskDescription = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task Title", text: $taskTitle)
                    TextField("Description", text: $taskDescription)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addTask(title: taskTitle, description: taskDescription, projectId: projectId)
                        dismiss()
                    }
                    .disabled(taskTitle.isEmpty)
                }
            }
        }
    }
}

struct ProjectSitemapView: View {
    let project: ConstructionProject
    @Environment(\.dismiss) var dismiss

    var body: some View {
        let latitude = project.latitude ?? 6.9271
        let longitude = project.longitude ?? 79.8612
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        NavigationStack {
            Map(initialPosition: .region(MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            ))) {
                Marker(project.name, coordinate: coordinate)
                    .tint(.orange)
            }
            .navigationTitle("Site Location Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
    }
}

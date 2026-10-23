import SwiftUI
import MapKit

// MARK: - Project Detail View
struct ProjectDetailView: View {
    let project: ConstructionProject
    @ObservedObject var viewModel: ProjectsViewModel
    @State private var showingSitemap = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Header Banner
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
                        Text(project.location)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding()
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Metadata Card
                SurfaceCard {
                    HStack {
                        Text("Project Status").font(.headline).foregroundStyle(AppTheme.ink)
                        Spacer()
                        StatusPill(text: project.status, color: project.status == "Attention" ? AppTheme.red : AppTheme.green)
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

                // Tasks & Checkboxes Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Milestones & Tasks")
                        .font(.title2.bold())
                        .foregroundStyle(AppTheme.ink)

                    let taskList = project.tasks ?? []
                    if taskList.isEmpty {
                        Text("No tasks assigned yet.")
                            .foregroundStyle(AppTheme.secondary)
                    } else {
                        ForEach(taskList) { task in
                            SurfaceCard {
                                HStack(spacing: 12) {
                                    Button {
                                        if let taskId = task.id {
                                            viewModel.toggleTaskCompletion(for: project.projectId, taskID: taskId)
                                        }
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

                                        let priorityStr = task.priority ?? "Normal"
                                        Text("Priority: \(priorityStr)")
                                            .font(.caption2)
                                            .foregroundStyle(AppTheme.secondary)
                                    }
                                    Spacer()
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
        .sheet(isPresented: $showingSitemap) {
            ProjectSitemapView(project: project)
        }
    }
}

// MARK: - Project Sitemap View
struct ProjectSitemapView: View {
    let project: ConstructionProject
    @Environment(\.dismiss) var dismiss

    var body: some View {
        let latitude = project.latitude ?? 37.7749
        let longitude = project.longitude ?? -122.4194
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

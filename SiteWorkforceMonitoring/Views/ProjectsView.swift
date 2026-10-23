import SwiftUI
import MapKit

// MARK: - Projects Overview View
struct ProjectsView: View {
    @StateObject private var viewModel = ProjectsViewModel()
    @State private var showingAddProject = false

    private let columns = [GridItem(.adaptive(minimum: 290), spacing: 14)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    
                    // Header & Add Button
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Projects")
                                .font(.largeTitle.bold())
                                .foregroundStyle(AppTheme.ink)
                            Text("Construction project overview")
                                .foregroundStyle(AppTheme.secondary)
                        }
                        Spacer()
                        Button {
                            showingAddProject = true
                        } label: {
                            Label("Add Project", systemImage: "plus")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(AppTheme.orange)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }

                    // Summary Grid
                    LazyVGrid(columns: columns, spacing: 12) {
                        summaryCard(title: "Total Projects", value: "\(viewModel.projects.count)", icon: "building.2.fill", color: AppTheme.orange)
                        summaryCard(title: "Average Progress", value: "\(Int(viewModel.averageProgress * 100))%", icon: "chart.bar.fill", color: AppTheme.blue)
                        summaryCard(title: "Workers Assigned", value: "\(viewModel.totalWorkersAssigned)", icon: "person.3.fill", color: AppTheme.green)
                        summaryCard(title: "Need Attention", value: "\(viewModel.projectsNeedingAttention)", icon: "exclamationmark.triangle.fill", color: AppTheme.red)
                    }

                    // Search Bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(AppTheme.secondary)
                        TextField("Search project or location", text: $viewModel.searchText)
                    }
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.black.opacity(0.05)))

                    // Status Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.statusOptions, id: \.self) { status in
                                Button {
                                    viewModel.selectedStatus = status
                                } label: {
                                    Text(status)
                                        .font(.subheadline.weight(.medium))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 9)
                                        .background(viewModel.selectedStatus == status ? AppTheme.orange : Color.white)
                                        .foregroundStyle(viewModel.selectedStatus == status ? .white : AppTheme.ink)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(Color.black.opacity(viewModel.selectedStatus == status ? 0 : 0.08)))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Directory Header
                    HStack {
                        Text("Project Directory")
                            .font(.title2.bold())
                            .foregroundStyle(AppTheme.ink)
                        Spacer()
                        Text("\(viewModel.filteredProjects.count) projects")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondary)
                    }

                    // Grid List
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(viewModel.filteredProjects) { project in
                            NavigationLink(destination: ProjectDetailView(project: project, viewModel: viewModel)) {
                                projectCard(project)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if viewModel.filteredProjects.isEmpty {
                        ContentUnavailableView.search(text: viewModel.searchText)
                    }
                }
                .padding()
                .frame(maxWidth: 1100)
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Projects")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddProject) {
                AddProjectModal(viewModel: viewModel)
            }
        }
    }

    private func summaryCard(title: String, value: String, icon: String, color: Color) -> some View {
        SurfaceCard {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(value).font(.title.bold()).foregroundStyle(AppTheme.ink)
                    Text(title).font(.subheadline).foregroundStyle(AppTheme.secondary)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private func projectCard(_ project: ConstructionProject) -> some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    Image(systemName: (project.imageName?.isEmpty == false) ? project.imageName! : "building.2.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(AppTheme.orange)
                        .frame(width: 48, height: 48)
                        .background(AppTheme.orange.opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(project.name).font(.headline).foregroundStyle(AppTheme.ink)
                        Text(project.location).font(.subheadline).foregroundStyle(AppTheme.secondary).lineLimit(2)
                    }
                    Spacer(minLength: 4)
                    StatusPill(text: project.status, color: project.status == "On track" ? AppTheme.green : AppTheme.orange)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Project Progress").font(.subheadline).foregroundStyle(AppTheme.ink)
                        Spacer()
                        Text("\(Int(project.progress * 100))%").font(.subheadline.bold()).foregroundStyle(AppTheme.maroon)
                    }
                    GradientProgressView(progress: project.progress)
                }

                Divider()

                HStack {
                    Label("\(project.workersAssigned ?? 0) workers", systemImage: "person.3.fill")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondary)
                    Spacer()
                    Text("View Details")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.orange)
                }
            }
        }
    }
}

// MARK: - Embedded Add Project Modal
struct AddProjectModal: View {
    @ObservedObject var viewModel: ProjectsViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var location = ""
    @State private var description = ""
    @State private var workersCount = "10"
    @State private var startDate = "Jan 2026"
    @State private var completionDate = "Dec 2026"
    @State private var latitude = "6.9271"
    @State private var longitude = "79.8612"

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Project Info")) {
                    TextField("Project Name", text: $name)
                    TextField("Location", text: $location)
                    TextField("Description", text: $description)
                }

                Section(header: Text("Timeline & Workforce")) {
                    TextField("Workers Assigned", text: $workersCount)
                        .keyboardType(.numberPad)
                    TextField("Start Date", text: $startDate)
                    TextField("Expected Completion", text: $completionDate)
                }

                Section(header: Text("Coordinates")) {
                    TextField("Latitude", text: $latitude)
                        .keyboardType(.decimalPad)
                    TextField("Longitude", text: $longitude)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let workers = Int(workersCount) ?? 10
                        let lat = Double(latitude) ?? 6.9271
                        let lon = Double(longitude) ?? 79.8612
                        
                        viewModel.addProject(
                            name: name,
                            location: location,
                            description: description,
                            status: "On track",
                            startDate: startDate,
                            completionDate: completionDate,
                            workersCount: workers,
                            latitude: lat,
                            longitude: lon
                        )
                        dismiss()
                    }
                    .disabled(name.isEmpty || location.isEmpty)
                }
            }
        }
    }
}


import SwiftUI
import MapKit

struct ProjectsView: View {
    @StateObject private var viewModel = ProjectsViewModel()

    private let orange = Color(
        red: 0.95,
        green: 0.39,
        blue: 0.10
    )

    private let columns = [
        GridItem(.adaptive(minimum: 290), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {

                    // Header
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Projects")
                            .font(.largeTitle.bold())

                        Text("Construction project overview")
                            .foregroundStyle(.secondary)
                    }

                    // Summary cards
                    LazyVGrid(columns: columns, spacing: 12) {
                        summaryCard(
                            title: "Total Projects",
                            value: "\(viewModel.projects.count)",
                            icon: "building.2.fill",
                            color: orange
                        )

                        summaryCard(
                            title: "Average Progress",
                            value: "\(Int(viewModel.averageProgress * 100))%",
                            icon: "chart.bar.fill",
                            color: .blue
                        )

                        summaryCard(
                            title: "Workers Assigned",
                            value: "\(viewModel.totalWorkersAssigned)",
                            icon: "person.3.fill",
                            color: .green
                        )

                        summaryCard(
                            title: "Need Attention",
                            value: "\(viewModel.projectsNeedingAttention)",
                            icon: "exclamationmark.triangle.fill",
                            color: .red
                        )
                    }

                    // Search
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)

                        TextField(
                            "Search project or location",
                            text: $viewModel.searchText
                        )
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Status filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(
                                viewModel.statusOptions,
                                id: \.self
                            ) { status in
                                Button {
                                    viewModel.selectedStatus = status
                                } label: {
                                    Text(status)
                                        .font(.subheadline.weight(.medium))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 9)
                                        .background(
                                            viewModel.selectedStatus == status
                                            ? orange
                                            : Color(.secondarySystemBackground)
                                        )
                                        .foregroundStyle(
                                            viewModel.selectedStatus == status
                                            ? .white
                                            : .primary
                                        )
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Project directory
                    HStack {
                        Text("Project Directory")
                            .font(.title2.bold())

                        Spacer()

                        Text("\(viewModel.filteredProjects.count) projects")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(viewModel.filteredProjects) { project in
                            projectCard(project)
                        }
                    }

                    if viewModel.filteredProjects.isEmpty {
                        ContentUnavailableView.search(
                            text: viewModel.searchText
                        )
                    }

                    Text("Project information is sample data.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: 1100)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Projects")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Summary Card

    private func summaryCard(
        title: String,
        value: String,
        icon: String,
        color: Color
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title.bold())

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Project Card

    private func projectCard(
        _ project: ConstructionProject
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack(alignment: .top) {
                Image(systemName: "building.2.crop.circle.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(orange)

                VStack(alignment: .leading, spacing: 5) {
                    Text(project.name)
                        .font(.headline)

                    Text(project.location)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 4)

                statusBadge(project.status)
            }

            // Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Project Progress")
                        .font(.subheadline)

                    Spacer()

                    Text("\(Int(project.progress * 100))%")
                        .font(.subheadline.bold())
                }

                ProgressView(value: project.progress)
                    .tint(orange)
            }

            Divider()

            HStack {
                Label(
                    "\(project.workersAssigned) workers",
                    systemImage: "person.3.fill"
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Spacer()

                Image(systemName: "location.fill")
                    .foregroundStyle(orange)

                Text("View location")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(orange)
            }

            // Static map preview
            Map(
                initialPosition: .region(
                    MKCoordinateRegion(
                        center: project.coordinate,
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.015,
                            longitudeDelta: 0.015
                        )
                    )
                )
            ) {
                Marker(
                    project.name,
                    coordinate: project.coordinate
                )
                .tint(.orange)
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .allowsHitTesting(false)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Status Badge

    private func statusBadge(_ status: String) -> some View {
        Text(status)
            .font(.caption.weight(.semibold))
            .foregroundStyle(
                status == "On track" ? .green : .orange
            )
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                (status == "On track" ? Color.green : Color.orange)
                    .opacity(0.12)
            )
            .clipShape(Capsule())
    }
}

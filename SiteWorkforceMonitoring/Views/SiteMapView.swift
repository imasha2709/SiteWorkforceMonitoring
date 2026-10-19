import SwiftUI
import MapKit

struct SiteMapView: View {
    @StateObject private var viewModel = SiteMapViewModel()

    @State private var cameraPosition: MapCameraPosition =
        .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: 6.94,
                    longitude: 79.88
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: 0.18,
                    longitudeDelta: 0.18
                )
            )
        )

    private let orange = Color(
        red: 0.95,
        green: 0.39,
        blue: 0.10
    )

    private let columns = [
        GridItem(.adaptive(minimum: 280), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Header
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Site Map")
                            .font(.largeTitle.bold())

                        Text("Construction sites and attendance register")
                            .foregroundStyle(.secondary)
                    }

                    // Interactive map
                    Map(position: $cameraPosition) {
                        ForEach(viewModel.projects) { project in
                            Annotation(
                                project.name,
                                coordinate: project.coordinate,
                                anchor: .bottom
                            ) {
                                mapAnnotationButton(for: project)
                            }
                        }
                    }
                    .frame(height: 330)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    Text("Select a construction site")
                        .font(.title2.bold())

                    // Site selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            Button {
                                viewModel.selectedProjectName = nil
                            } label: {
                                Text("All Sites")
                                    .font(.subheadline.weight(.medium))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(
                                        viewModel.selectedProjectName == nil
                                        ? orange
                                        : Color(.secondarySystemBackground)
                                    )
                                    .foregroundStyle(
                                        viewModel.selectedProjectName == nil
                                        ? .white
                                        : .primary
                                    )
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)

                            ForEach(viewModel.projects) { project in
                                Button {
                                    selectProject(project)
                                } label: {
                                    Text(project.name)
                                        .font(.subheadline.weight(.medium))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .background(
                                            viewModel.selectedProjectName == project.name
                                            ? orange
                                            : Color(.secondarySystemBackground)
                                        )
                                        .foregroundStyle(
                                            viewModel.selectedProjectName == project.name
                                            ? .white
                                            : .primary
                                        )
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    // Selected project details
                    if let project = viewModel.selectedProject {
                        projectDetails(project)
                    } else {
                        allSitesSummary
                    }

                    Divider()

                    // Attendance register
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Attendance Register")
                            .font(.title2.bold())

                        Text(
                            viewModel.selectedProjectName ??
                            "Showing records from all sites"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }

                    // Search
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)

                        TextField(
                            "Search worker or site",
                            text: $viewModel.searchText
                        )
                    }
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Attendance filters
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
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
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

                    // Attendance summary
                    LazyVGrid(columns: columns, spacing: 10) {
                        attendanceCount(
                            "Present",
                            count: viewModel.count(for: .present),
                            color: .green
                        )

                        attendanceCount(
                            "Late",
                            count: viewModel.count(for: .late),
                            color: .orange
                        )

                        attendanceCount(
                            "Absent",
                            count: viewModel.count(for: .absent),
                            color: .red
                        )
                    }

                    // Register rows
                    if viewModel.filteredAttendance.isEmpty {
                        ContentUnavailableView(
                            "No Attendance Records",
                            systemImage: "person.crop.rectangle",
                            description: Text(
                                "Try another site, search term, or status."
                            )
                        )
                        .frame(maxWidth: .infinity)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(
                                viewModel.filteredAttendance
                            ) { record in
                                attendanceRow(record)
                            }
                        }
                    }

                    Text("Demo data only. Attendance is not saved.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: 1100)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Site Map")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Map Annotation Builder (Prevents type-checking timeout)

    @ViewBuilder
    private func mapAnnotationButton(for project: ConstructionProject) -> some View {
        Button {
            selectProject(project)
        } label: {
            VStack(spacing: 3) {
                Image(
                    systemName:
                        viewModel.selectedProjectName == project.name
                        ? "building.2.crop.circle.fill"
                        : "mappin.circle.fill"
                )
                .font(
                    .system(
                        size: viewModel.selectedProjectName == project.name ? 38 : 30
                    )
                )
                .foregroundStyle(
                    project.status == "Attention" ? .red : orange
                )

                Text(project.name)
                    .font(.caption2.bold())
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.horizontal, 5)
                    .padding(.vertical, 3)
                    .background(.regularMaterial)
                    .clipShape(Capsule())
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Select Site

    private func selectProject(_ project: ConstructionProject) {
        viewModel.selectedProjectName = project.name

        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: project.coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.035,
                        longitudeDelta: 0.035
                    )
                )
            )
        }
    }

    // MARK: - Project Details

    private func projectDetails(
        _ project: ConstructionProject
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "building.2.fill")
                    .font(.title2)
                    .foregroundStyle(orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name)
                        .font(.headline)

                    Text(project.location)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(project.status)
                    .font(.caption.bold())
                    .foregroundStyle(
                        project.status == "Attention" ? .red : .green
                    )
                    .padding(8)
                    .background(
                        (project.status == "Attention"
                        ? Color.red : Color.green).opacity(0.12)
                    )
                    .clipShape(Capsule())
            }

            HStack {
                Text("Project progress")
                Spacer()
                Text("\(Int(project.progress * 100))%")
                    .bold()
            }
            .font(.subheadline)

            ProgressView(value: project.progress)
                .tint(orange)

            Label(
                "\(project.workersAssigned) assigned workers",
                systemImage: "person.3.fill"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Button {
                let coordinate = project.coordinate
                let mapItem = MKMapItem(
                    placemark: MKPlacemark(coordinate: coordinate)
                )
                mapItem.name = project.name
                mapItem.openInMaps()
            } label: {
                Label("Open in Apple Maps", systemImage: "map")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(orange.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .tint(orange)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - All Sites Summary

    private var allSitesSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("All Construction Sites")
                .font(.headline)

            Text("\(viewModel.projects.count) sites")
                .foregroundStyle(.secondary)

            Text(
                "\(viewModel.projects.reduce(0) { $0 + $1.workersAssigned }) assigned workers across the listed projects"
            )
            .font(.subheadline)

            Text("Select a site marker to see its details and attendance.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Attendance Count

    private func attendanceCount(
        _ title: String,
        count: Int,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("\(count)")
                .font(.title2.bold())

            Text(title)
                .font(.subheadline)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Attendance Row

    private func attendanceRow(
        _ record: AttendanceRecord
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(orange)

            VStack(alignment: .leading, spacing: 5) {
                Text(record.workerName)
                    .font(.headline)

                Text(record.site)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Label(
                    "Check-in: \(record.checkIn)",
                    systemImage: "clock"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 4)

            Text(record.status.rawValue)
                .font(.caption.weight(.semibold))
                .foregroundStyle(statusColor(record.status))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(statusColor(record.status).opacity(0.12))
                .clipShape(Capsule())
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Status Color (Fixed to AttendanceStatus)

    private func statusColor(_ status: AttendanceStatus) -> Color {
        switch status {
        case .present:
            return .green
        case .late:
            return .orange
        case .absent:
            return .red
        }
    }
}

import SwiftUI
import MapKit

struct SiteMapView: View {
    @StateObject private var viewModel = SiteMapViewModel()
    
    
    @State private var mapStyleOption: MapStyleOption = .hybrid
    
   
    @State private var showingAttendanceSheet = false
    @State private var selectedWorkerForAttendance = ""

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

    private let orange = Color(red: 0.95, green: 0.39, blue: 0.10)

    enum MapStyleOption: String, CaseIterable {
        case standard = "Standard"
        case hybrid = "Satellite & Roads"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                  
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Site Map & Paths")
                                .font(.largeTitle.bold())

                            Text("Inspect site terrain, roads, and record attendance")
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        
                        Picker("Map Style", selection: $mapStyleOption) {
                            ForEach(MapStyleOption.allCases, id: \.self) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 170)
                    }

               
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
                    .mapStyle(mapStyleOption == .hybrid ? .hybrid(elevation: .realistic) : .standard)
                    .frame(height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(alignment: .topTrailing) {
                        
                        Button {
                            showingAttendanceSheet = true
                        } label: {
                            Label("Mark Attendance", systemImage: "checkmark.circle.badge.plus")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.regularMaterial)
                                .clipShape(Capsule())
                        }
                        .padding(12)
                        .buttonStyle(.plain)
                    }

                  
                    if let project = viewModel.selectedProject {
                        projectDetailsWithActions(project)
                    } else {
                        allSitesSummary
                    }

                    Divider()

               
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Live Attendance Log")
                                .font(.title2.bold())
                            Text(viewModel.selectedProjectName ?? "All Sites")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            showingAttendanceSheet = true
                        } label: {
                            Label("New Check-in", systemImage: "plus")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(orange)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }

                   
                    if viewModel.filteredAttendance.isEmpty {
                        ContentUnavailableView(
                            "No Records",
                            systemImage: "person.crop.rectangle",
                            description: Text("No attendance logged for this site yet.")
                        )
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(viewModel.filteredAttendance) { record in
                                attendanceRow(record)
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 1100)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Site Map")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAttendanceSheet) {
                QuickAttendanceCheckInView(siteName: viewModel.selectedProjectName ?? "Colombo Tower")
            }
        }
    }

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
                .font(.system(size: viewModel.selectedProjectName == project.name ? 40 : 32))
                .foregroundStyle(project.status == "Attention" ? .red : orange)

                Text(project.name)
                    .font(.caption2.bold())
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.regularMaterial)
                    .clipShape(Capsule())
            }
        }
        .buttonStyle(.plain)
    }

    private func selectProject(_ project: ConstructionProject) {
        viewModel.selectedProjectName = project.name
        withAnimation {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: project.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                )
            )
        }
    }

    private func projectDetailsWithActions(_ project: ConstructionProject) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "building.2.fill")
                    .font(.title2)
                    .foregroundStyle(orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text(project.name).font(.headline)
                    Text(project.location).font(.subheadline).foregroundStyle(.secondary)
                }

                Spacer()

                Text(project.status)
                    .font(.caption.bold())
                    .foregroundStyle(project.status == "Attention" ? .red : .green)
                    .padding(8)
                    .background((project.status == "Attention" ? Color.red : Color.green).opacity(0.12))
                    .clipShape(Capsule())
            }

            Text(project.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text("Progress")
                Spacer()
                Text("\(Int(project.progress * 100))%").bold()
            }
            .font(.subheadline)

            ProgressView(value: project.progress).tint(orange)

            HStack(spacing: 12) {
                Button {
                    showingAttendanceSheet = true
                } label: {
                    Label("Mark Attendance", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button {
                    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: project.coordinate))
                    mapItem.name = project.name
                    mapItem.openInMaps()
                } label: {
                    Label("Directions", systemImage: "map")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(orange.opacity(0.12))
                        .foregroundStyle(orange)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var allSitesSummary: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("All Construction Sites Overview").font(.headline)
            Text("\(viewModel.projects.count) active sites with satellite tracking enabled.").font(.subheadline).foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func attendanceRow(_ record: AttendanceRecord) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(orange)

            VStack(alignment: .leading, spacing: 4) {
                Text(record.workerName).font(.headline)
                Text(record.site).font(.caption).foregroundStyle(.secondary)
                Text("Check-in: \(record.checkIn)").font(.caption2).foregroundStyle(.secondary)
            }

            Spacer()

            Text(record.status.rawValue)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(record.status == .present ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                .foregroundStyle(record.status == .present ? .green : .orange)
                .clipShape(Capsule())
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

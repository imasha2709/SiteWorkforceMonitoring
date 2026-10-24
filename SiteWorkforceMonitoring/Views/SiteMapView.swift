import SwiftUI
import MapKit
import FirebaseCore
import FirebaseFirestore

struct SiteMapView: View {
    @StateObject private var viewModel = SiteMapViewModel()
    @State private var mapStyleOption: MapStyleOption = .hybrid
    @State private var showingAttendanceSheet = false

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 6.94, longitude: 79.88),
            span: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)
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

                    // MARK: - Header & Style Picker
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Interactive Site Map")
                                .font(.largeTitle.bold())
                            Text("Live terrain, routing, & geofenced check-ins")
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

                    // MARK: - Active Geofence Alert Banner
                    if let alertMessage = viewModel.activeGeofenceAlert {
                        HStack(spacing: 12) {
                            Image(systemName: viewModel.isInsideGeofence ? "scope" : "exclamationmark.triangle.fill")
                                .foregroundStyle(viewModel.isInsideGeofence ? .green : .orange)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(viewModel.isInsideGeofence ? "Geofence Entry Detected" : "Geofence Notice")
                                    .font(.subheadline.bold())
                                Text(alertMessage)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(viewModel.isInsideGeofence ? Color.green.opacity(0.12) : Color.orange.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // MARK: - Interactive Map View
                    Map(position: $cameraPosition) {
                        // User Location Marker
                        if let userLoc = viewModel.userLocation {
                            Annotation("My Location", coordinate: userLoc) {
                                ZStack {
                                    Circle().fill(Color.blue.opacity(0.3)).frame(width: 32, height: 32)
                                    Circle().fill(Color.blue).frame(width: 14, height: 14)
                                    Circle().stroke(Color.white, lineWidth: 2).frame(width: 14, height: 14)
                                }
                            }
                        }

                        // Project Pins & Geofence Circles
                        ForEach(viewModel.projects) { project in
                            Annotation(
                                project.name,
                                coordinate: project.coordinate,
                                anchor: .bottom
                            ) {
                                mapAnnotationButton(for: project)
                            }

                            // Show visual geofence radius circle around selected project
                            if viewModel.selectedProjectName == project.name {
                                MapCircle(center: project.coordinate, radius: viewModel.geofenceRadiusMeters)
                                    .foregroundStyle(viewModel.isInsideGeofence ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
                                    .stroke(viewModel.isInsideGeofence ? Color.green : Color.orange, lineWidth: 2)
                            }
                        }

                        // Render Route Polyline if calculated
                        if !viewModel.routeCoordinates.isEmpty {
                            MapPolyline(coordinates: viewModel.routeCoordinates)
                                .stroke(orange, lineWidth: 5)
                        }
                    }
                    .mapStyle(mapStyleOption == .hybrid ? .hybrid(elevation: .realistic) : .standard)
                    .frame(height: 380)
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

                    // MARK: - Navigation Details Banner
                    if let time = viewModel.travelTime, let dist = viewModel.distanceText, let name = viewModel.selectedProjectName {
                        HStack {
                            Label("Route to \(name): \(dist) (\(time))", systemImage: "car.fill")
                                .font(.subheadline.bold())
                                .foregroundStyle(orange)
                            Spacer()
                            Button("Clear Route") {
                                viewModel.routeCoordinates = []
                                viewModel.travelTime = nil
                                viewModel.distanceText = nil
                            }
                            .font(.caption.bold())
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    // MARK: - Selected Project Details or Overview
                    if let project = viewModel.selectedProject {
                        projectDetailsWithActions(project)
                    } else {
                        allSitesSummary
                    }

                    Divider()

                    // MARK: - Live Attendance Section
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

                    // Attendance Record Feed
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
                    systemName: viewModel.selectedProjectName == project.name
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
                    Text(project.location ?? "No location provided")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(viewModel.isInsideGeofence ? "Inside Geofence" : "Outside Zone")
                    .font(.caption.bold())
                    .foregroundStyle(viewModel.isInsideGeofence ? .green : .orange)
                    .padding(8)
                    .background((viewModel.isInsideGeofence ? Color.green : Color.orange).opacity(0.12))
                    .clipShape(Capsule())
            }

            Text(project.description ?? "No description available.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Live Worker Stats
            HStack {
                Label("\(viewModel.currentSiteWorkerCount) Workers Active", systemImage: "person.3.fill")
                    .font(.subheadline.bold())
                    .foregroundStyle(orange)
                Spacer()
                Text("Progress: \(Int(project.progress * 100))%")
                    .bold()
            }
            .font(.subheadline)

            ProgressView(value: project.progress).tint(orange)

            // Action Buttons
            HStack(spacing: 12) {
                Button {
                    showingAttendanceSheet = true
                } label: {
                    Label("Check-In", systemImage: "checkmark.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.calculateRoute(to: project.coordinate)
                } label: {
                    Label("Show Route", systemImage: "map.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(orange.opacity(0.15))
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
            Text("\(viewModel.projects.count) active sites with live geofencing and path tracking enabled.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
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
                Text("Site: \(record.siteId)").font(.caption).foregroundStyle(.secondary)
                
                if let timestamp = record.checkIn {
                    let date = timestamp.dateValue()
                    Text("Check-in: \(date.formatted(date: .omitted, time: .shortened))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Check-in: N/A")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
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

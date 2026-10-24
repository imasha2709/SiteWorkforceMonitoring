import SwiftUI

struct WorkersView: View {
    @StateObject private var viewModel = WorkersViewModel()
    @EnvironmentObject var authentication: AuthenticationViewModel
    @State private var showingAddWorker = false

    // AppStorage key for the Dark Mode toggle in Settings
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = false

    private let columns = [GridItem(.adaptive(minimum: 280), spacing: 12)]

    var body: some View {
        Group {
            if authentication.currentUser?.role.canViewWorkers == true {
                workersContent
            } else {
                ContentUnavailableView(
                    "Access Restricted",
                    systemImage: "lock.fill",
                    description: Text("Only project managers and site supervisors can view the worker directory.")
                )
            }
        }
        // Apply dark/light color scheme dynamically based on toggle state
        .preferredColorScheme(isDarkModeEnabled ? .dark : .light)
    }

    private var workersContent: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Workers")
                                .font(.largeTitle.bold())
                                .foregroundStyle(AppTheme.ink)
                            Text("Manage your construction workforce")
                                .foregroundStyle(AppTheme.secondary)
                        }
                        Spacer()
                        
                        Button {
                            showingAddWorker = true
                        } label: {
                            Label("Add", systemImage: "plus")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(AppTheme.orange)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }

                    LazyVGrid(columns: columns, spacing: 12) {
                        summaryCard(title: "Total Workers", count: viewModel.workers.count, icon: "person.3.fill", color: AppTheme.orange)
                        summaryCard(title: "Present", count: viewModel.count(for: .present), icon: "checkmark.circle.fill", color: AppTheme.green)
                        summaryCard(title: "Late", count: viewModel.count(for: .late), icon: "clock.fill", color: AppTheme.orange)
                        summaryCard(title: "Absent", count: viewModel.count(for: .absent), icon: "xmark.circle.fill", color: AppTheme.red)
                    }

                    // Adaptive Search Bar for Light/Dark Mode
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(AppTheme.secondary)
                        TextField("Search name, role or site", text: $viewModel.searchText)
                    }
                    .padding(12)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

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
                                        .background(viewModel.selectedStatus == status ? AppTheme.orange : Color(.secondarySystemBackground))
                                        .foregroundStyle(viewModel.selectedStatus == status ? .white : AppTheme.ink)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    HStack {
                        Text("Worker Directory")
                            .font(.title2.bold())
                            .foregroundStyle(AppTheme.ink)
                        Spacer()
                        Text("\(viewModel.filteredWorkers.count) workers")
                            .font(.caption)
                            .foregroundStyle(AppTheme.secondary)
                    }

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.filteredWorkers) { worker in
                            NavigationLink(destination: WorkerDetailView(worker: worker, viewModel: viewModel)) {
                                workerCard(worker)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if viewModel.filteredWorkers.isEmpty {
                        ContentUnavailableView.search(text: viewModel.searchText)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .frame(maxWidth: 1100)
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Workers")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddWorker) {
                AddWorkerModal(viewModel: viewModel)
            }
        }
    }

    private func summaryCard(title: String, count: Int, icon: String, color: Color) -> some View {
        SurfaceCard {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 42, height: 42)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(count)").font(.title.bold()).foregroundStyle(AppTheme.ink)
                    Text(title).font(.subheadline).foregroundStyle(AppTheme.secondary)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private func workerCard(_ worker: Worker) -> some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Text(worker.initials)
                        .font(.headline.bold())
                        .foregroundStyle(AppTheme.orange)
                        .frame(width: 48, height: 48)
                        .background(AppTheme.orange.opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(worker.name).font(.headline).foregroundStyle(AppTheme.ink).lineLimit(1)
                        Text(worker.role).font(.subheadline).foregroundStyle(AppTheme.secondary)
                    }
                    Spacer(minLength: 0)
                }

                Label(worker.site, systemImage: "building.2")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondary)

                HStack {
                    StatusPill(text: worker.status.rawValue, color: statusColor(worker.status))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.orange)
                }
            }
        }
    }

    private func statusColor(_ status: AttendanceStatus) -> Color {
        switch status {
        case .present: return AppTheme.green
        case .late: return AppTheme.orange
        case .absent: return AppTheme.red
        }
    }
}

struct AddWorkerModal: View {
    @ObservedObject var viewModel: WorkersViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var role = "Mason"
    @State private var site = "Colombo Tower"
    @State private var status: AttendanceStatus = .present

    let roles = ["Site Supervisor", "Mason", "Electrician", "Carpenter", "General Worker", "Safety Officer"]
    let sites = ["Colombo Tower", "Kandy Road Project", "Harbour Extension"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Worker Information")) {
                    TextField("Full Name", text: $name)
                    
                    Picker("Role", selection: $role) {
                        ForEach(roles, id: \.self) { Text($0) }
                    }

                    Picker("Assigned Site", selection: $site) {
                        ForEach(sites, id: \.self) { Text($0) }
                    }
                }

                Section(header: Text("Initial Attendance Status")) {
                    Picker("Status", selection: $status) {
                        ForEach(AttendanceStatus.allCases) { st in
                            Text(st.rawValue).tag(st)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Register New Worker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addWorker(name: name, role: role, siteId: site, status: status)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

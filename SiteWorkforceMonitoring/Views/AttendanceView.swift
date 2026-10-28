import SwiftUI

struct AttendanceView: View {
    @StateObject private var viewModel = WorkersViewModel()
    @State private var selectedTab = 0
    
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = false

    private let columns = [
        GridItem(.adaptive(minimum: 280), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Attendance")
                            .font(.largeTitle.bold())
                            .foregroundStyle(AppTheme.ink)

                        Text("Daily workforce attendance overview")
                            .foregroundStyle(AppTheme.secondary)
                    }

                    Picker("Attendance Mode", selection: $selectedTab) {
                        Text("Overview").tag(0)
                        Text("Attendance Register").tag(1)
                    }
                    .pickerStyle(.segmented)

                    if selectedTab == 0 {
                        overviewContent
                    } else {
                        registerContent
                    }
                }
                .padding()
                .frame(maxWidth: 1100)
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Attendance")
            .navigationBarTitleDisplayMode(.inline)
        }

        .preferredColorScheme(isDarkModeEnabled ? .dark : .light)
    }

    private var overviewContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            LazyVGrid(columns: columns, spacing: 12) {
                summaryCard(title: "Present", count: viewModel.count(for: .present), color: AppTheme.green, icon: "checkmark.circle.fill")
                summaryCard(title: "Late", count: viewModel.count(for: .late), color: AppTheme.orange, icon: "clock.fill")
                summaryCard(title: "Absent", count: viewModel.count(for: .absent), color: AppTheme.red, icon: "xmark.circle.fill")
            }

         
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppTheme.secondary)

                TextField("Search worker or site", text: $viewModel.searchText)
            }
            .padding(12)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

          
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
                Text("Attendance Records")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.ink)

                Spacer()

                Text("\(viewModel.filteredWorkers.count) records")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondary)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.filteredWorkers) { worker in
                    workerAttendanceCard(worker)
                }
            }

            if viewModel.filteredWorkers.isEmpty {
                ContentUnavailableView(
                    "No Records Found",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("Try changing your search or status filter.")
                )
            }
        }
    }

    private var registerContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Daily Attendance Register")
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                Text("Tap buttons to update worker status for today.")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondary)
            }
            .padding(.bottom, 4)

            ForEach($viewModel.workers) { $worker in
                SurfaceCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Text(worker.initials)
                                .font(.headline.bold())
                                .foregroundStyle(AppTheme.orange)
                                .frame(width: 42, height: 42)
                                .background(AppTheme.orange.opacity(0.12))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(worker.name)
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.ink)
                                Text("\(worker.role)\n\(worker.site)")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.secondary)
                            }

                            Spacer()
                        }

                        Divider()

                        HStack(spacing: 8) {
                            ForEach(AttendanceStatus.allCases) { statusOption in
                                let isSelected = worker.status == statusOption
                                
                                Button {
                                    guard let workerId = worker.id else { return }
                                    viewModel.updateStatus(for: workerId, newStatus: statusOption)
                                } label: {
                                    Text(statusOption.rawValue)
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(isSelected ? statusColor(statusOption) : Color(.tertiarySystemBackground))
                                        .foregroundStyle(isSelected ? Color.white : AppTheme.ink)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
    }

    private func summaryCard(title: String, count: Int, color: Color, icon: String) -> some View {
        SurfaceCard {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 42, height: 42)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(count)")
                        .font(.title.bold())
                        .foregroundStyle(AppTheme.ink)

                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondary)
                }

                Spacer()
            }
        }
    }

    private func workerAttendanceCard(_ worker: Worker) -> some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    Text(worker.initials)
                        .font(.headline.bold())
                        .foregroundStyle(AppTheme.orange)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.orange.opacity(0.12))
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(worker.name)
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)

                        Text(worker.site)
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.secondary)
                    }

                    Spacer(minLength: 0)
                }

                Divider()

                HStack {
                    Label("Role: \(worker.role)", systemImage: "person.badge.shield.checkmark")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondary)

                    Spacer(minLength: 4)

                    StatusPill(text: worker.status.rawValue, color: statusColor(worker.status))
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

import SwiftUI

struct WorkersView: View {
    @StateObject private var viewModel = WorkersViewModel()
    @EnvironmentObject var authentication: AuthenticationViewModel

    private let orange = Color(
        red: 0.95,
        green: 0.39,
        blue: 0.10
    )

    private let columns = [
        GridItem(.adaptive(minimum: 280), spacing: 12)
    ]

    var body: some View {
        Group {
            if authentication.currentUser?.role.canViewWorkers == true {
                workersContent
            } else {
                ContentUnavailableView(
                    "Access Restricted",
                    systemImage: "lock.fill",
                    description: Text(
                        "Only project managers and site supervisors can view the worker directory."
                    )
                )
            }
        }
    }

    private var workersContent: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Workers")
                            .font(.largeTitle.bold())

                        Text("Manage your construction workforce")
                            .foregroundStyle(.secondary)
                    }

                    
                    LazyVGrid(
                        columns: columns,
                        spacing: 12
                    ) {
                        summaryCard(
                            title: "Total Workers",
                            count: viewModel.workers.count,
                            icon: "person.3.fill",
                            color: orange
                        )

                        summaryCard(
                            title: "Present",
                            count: viewModel.count(for: .present),
                            icon: "checkmark.circle.fill",
                            color: .green
                        )

                        summaryCard(
                            title: "Late",
                            count: viewModel.count(for: .late),
                            icon: "clock.fill",
                            color: .orange
                        )

                        summaryCard(
                            title: "Absent",
                            count: viewModel.count(for: .absent),
                            icon: "xmark.circle.fill",
                            color: .red
                        )
                    }

                 
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)

                        TextField(
                            "Search name, role or site",
                            text: $viewModel.searchText
                        )
                    }
                    .padding(12)
                    .background(
                        Color(.secondarySystemBackground)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )

                    
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

                    
                    HStack {
                        Text("Worker Directory")
                            .font(.title2.bold())

                        Spacer()

                        Text("\(viewModel.filteredWorkers.count) workers")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.filteredWorkers) { worker in
                            workerCard(worker)
                        }
                    }

                    if viewModel.filteredWorkers.isEmpty {
                        ContentUnavailableView.search(
                            text: viewModel.searchText
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .frame(maxWidth: 1100)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Workers")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    

    private func summaryCard(
        title: String,
        count: Int,
        icon: String,
        color: Color
    ) -> some View {
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

    
    private func workerCard(_ worker: Worker) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Text(worker.initials)
                    .font(.headline.bold())
                    .foregroundStyle(orange)
                    .frame(width: 48, height: 48)
                    .background(orange.opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(worker.name)
                        .font(.headline)
                        .lineLimit(2)

                    Text(worker.role)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }

            Label(worker.site, systemImage: "building.2")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                Circle()
                    .fill(statusColor(worker.status))
                    .frame(width: 8, height: 8)

                Text(worker.status.rawValue)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(statusColor(worker.status))

                Spacer()

                Image(systemName: "person.fill")
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }



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

import SwiftUI

struct AttendanceView: View {
    @StateObject private var viewModel = AttendanceViewModel()

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

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Attendance")
                            .font(.largeTitle.bold())

                        Text("Daily workforce attendance overview")
                            .foregroundStyle(.secondary)
                    }

                   
                    LazyVGrid(columns: columns, spacing: 12) {
                        summaryCard(
                            title: "Present",
                            count: viewModel.presentCount,
                            color: .green,
                            icon: "checkmark.circle.fill"
                        )

                        summaryCard(
                            title: "Late",
                            count: viewModel.lateCount,
                            color: .orange,
                            icon: "clock.fill"
                        )

                        summaryCard(
                            title: "Absent",
                            count: viewModel.absentCount,
                            color: .red,
                            icon: "xmark.circle.fill"
                        )
                    }

                    
                    HStack {
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
                        Text("Attendance Records")
                            .font(.title2.bold())

                        Spacer()

                        Text("\(viewModel.filteredRecords.count) records")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.filteredRecords) { record in
                            attendanceCard(record)
                        }
                    }

                    if viewModel.filteredRecords.isEmpty {
                        ContentUnavailableView(
                            "No Records Found",
                            systemImage: "calendar.badge.exclamationmark",
                            description: Text(
                                "Try changing your search or status filter."
                            )
                        )
                    }

                    Text("Demo data — not actual attendance.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: 1100)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Attendance")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func summaryCard(
        title: String,
        count: Int,
        color: Color,
        icon: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(count)")
                    .font(.title.bold())

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func attendanceCard(
        _ record: AttendanceRecord
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text(record.workerName)
                        .font(.headline)

                    Text(record.site)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }

            Divider()

            HStack {
                Label(
                    "Check-in: \(record.checkIn)",
                    systemImage: "clock"
                )
                .font(.subheadline)

                Spacer(minLength: 4)

                Text(record.status.rawValue)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(statusColor(record.status))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(statusColor(record.status).opacity(0.12))
                    .clipShape(Capsule())
            }
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

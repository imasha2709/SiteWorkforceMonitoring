import SwiftUI

struct AttendanceRegisterView: View {
    @ObservedObject var viewModel: WorkersViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Attendance Register")
                        .font(.title2.bold())
                        .foregroundStyle(AppTheme.ink)
                    Text("Mark or update worker attendance status for today.")
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
                                    Button {
                                  
                                        guard let workerId = worker.id else { return }
                                        viewModel.updateStatus(for: workerId, newStatus: statusOption)
                                    } label: {
                                        Text(statusOption.rawValue)
                                            .font(.subheadline.weight(.semibold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(
                                                worker.status == statusOption
                                                    ? statusColor(statusOption)
                                                    : Color(.secondarySystemBackground)
                                            )
                                            .foregroundStyle(
                                                worker.status == statusOption
                                                    ? .white
                                                    : AppTheme.ink
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Attendance Register")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func statusColor(_ status: AttendanceStatus) -> Color {
        switch status {
        case .present: return AppTheme.green
        case .late: return AppTheme.orange
        case .absent: return AppTheme.red
        }
    }
}

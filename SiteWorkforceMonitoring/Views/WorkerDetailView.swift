import SwiftUI

struct WorkerDetailView: View {
    let worker: Worker
    @ObservedObject var viewModel: WorkersViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                SurfaceCard {
                    HStack(spacing: 16) {
                        Text(worker.initials)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AppTheme.orange)
                            .frame(width: 64, height: 64)
                            .background(AppTheme.orange.opacity(0.12))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(worker.name)
                                .font(.title2.bold())
                                .foregroundStyle(AppTheme.ink)
                            Text(worker.role)
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.secondary)
                        }
                    }

                    Divider()

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Assigned Site")
                                .font(.caption)
                                .foregroundStyle(AppTheme.secondary)
                            Label(worker.site, systemImage: "building.2")
                                .font(.subheadline.bold())
                                .foregroundStyle(AppTheme.ink)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Current Status")
                                .font(.caption)
                                .foregroundStyle(AppTheme.secondary)
                            StatusPill(text: worker.status.rawValue, color: statusColor(worker.status))
                        }
                    }
                }

                NavigationLink(destination: WorkerAttendanceHistoryView(worker: worker, viewModel: viewModel)) {
                    SurfaceCard {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                                .font(.title2)
                                .foregroundStyle(AppTheme.orange)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Attendance History")
                                    .font(.headline)
                                    .foregroundStyle(AppTheme.ink)
                                Text("View past check-ins and logs")
                                    .font(.subheadline)
                                    .foregroundStyle(AppTheme.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(AppTheme.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)

            }
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Worker Profile")
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

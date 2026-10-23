import SwiftUI
import FirebaseFirestore

struct WorkerAttendanceHistoryView: View {
    let worker: Worker
    @ObservedObject var viewModel: WorkersViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Text("Attendance Logs for \(worker.name)")
                    .font(.headline)
                    .foregroundStyle(AppTheme.secondary)

                let records = viewModel.recordsForWorker(worker.name)

                if records.isEmpty {
                    SurfaceCard {
                        Text("No attendance records found.")
                            .foregroundStyle(AppTheme.secondary)
                    }
                } else {
                    ForEach(records) { record in
                        SurfaceCard {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(record.siteId)
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.ink)
                                    
                                    let checkInText = record.checkIn?.dateValue().formatted(date: .abbreviated, time: .shortened) ?? "N/A"
                                    Text("Check-in: \(checkInText)")
                                        .font(.subheadline)
                                        .foregroundStyle(AppTheme.secondary)
                                }

                                Spacer()

                                StatusPill(text: record.status.rawValue, color: statusColor(record.status))
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Attendance History")
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

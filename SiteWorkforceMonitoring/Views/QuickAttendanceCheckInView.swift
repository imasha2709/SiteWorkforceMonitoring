import SwiftUI

struct QuickAttendanceCheckInView: View {
    let siteName: String
    @Environment(\.dismiss) var dismiss
    
    @State private var workerName = ""
    @State private var selectedStatus: AttendanceStatus = .present
    @State private var note = ""

    private let orange = Color(red: 0.95, green: 0.39, blue: 0.10)

    var body: some View {
        NavigationStack {
            Form {
                Section("Site Information") {
                    LabeledContent("Location", value: siteName)
                    LabeledContent("Time", value: Date().formatted(date: .omitted, time: .shortened))
                }

                Section("Worker Details") {
                    TextField("Worker Full Name", text: $workerName)
                    
                    Picker("Attendance Status", selection: $selectedStatus) {
                        ForEach(AttendanceStatus.allCases) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                }

                Section("Supervisor Notes") {
                    TextField("Optional notes (e.g. late due to traffic)", text: $note)
                }
            }
            .navigationTitle("Mark Attendance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Check-in") {
                        // Here you would normally add the record to your data store or view model
                        dismiss()
                    }
                    .disabled(workerName.isEmpty)
                }
            }
        }
    }
}

import SwiftUI
import FirebaseFirestore

struct QuickAttendanceCheckInView: View {
    let siteName: String
    @Environment(\.dismiss) var dismiss
    
    @State private var workerName = ""
    @State private var selectedStatus: AttendanceStatus = .present
    @State private var note = ""
    @State private var isSubmitting = false

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
                        Text("Present").tag(AttendanceStatus.present)
                        Text("Late").tag(AttendanceStatus.late)
                        Text("Absent").tag(AttendanceStatus.absent)
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
                        submitAttendanceRecord()
                    }
                    .disabled(workerName.isEmpty || isSubmitting)
                }
            }
        }
    }

    private func submitAttendanceRecord() {
        isSubmitting = true
        let db = Firestore.firestore()
        
        let attendanceData: [String: Any] = [
            "workerName": workerName,
            "siteId": siteName, 
            "checkIn": FieldValue.serverTimestamp(),
            "status": selectedStatus.rawValue,
            "note": note
        ]
        
        db.collection("attendance").addDocument(data: attendanceData) { error in
            isSubmitting = false
            if let error = error {
                print("❌ Error saving attendance: \(error.localizedDescription)")
            } else {
                print("✅ Successfully checked in worker: \(workerName) for site: \(siteName)")
                dismiss()
            }
        }
    }
}

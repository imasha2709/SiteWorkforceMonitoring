import SwiftUI

struct AddWorkerView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: WorkersViewModel

    @State private var name = ""
    @State private var role = "Mason"
    @State private var site = "Colombo Tower"
    
    let roles = ["Site Supervisor", "Mason", "Electrician", "Carpenter", "General Worker", "Safety Officer"]
    let sites = ["Colombo Tower", "Kandy Road Project", "Harbour Extension", "Skyline Tower A"]

    private let orange = Color(red: 0.95, green: 0.39, blue: 0.10)

    var body: some View {
        NavigationStack {
            Form {
                Section("Worker Information") {
                    TextField("Full Name", text: $name)

                    Picker("Role", selection: $role) {
                        ForEach(roles, id: \.self) { r in
                            Text(r).tag(r)
                        }
                    }

                    Picker("Assigned Site", selection: $site) {
                        ForEach(sites, id: \.self) { s in
                            Text(s).tag(s)
                        }
                    }
                }
            }
            .navigationTitle("Add New Worker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addWorker(name: name, role: role, site: site)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

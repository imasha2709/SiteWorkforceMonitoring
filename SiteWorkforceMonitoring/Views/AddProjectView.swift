import SwiftUI
import CoreLocation

struct AddProjectView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProjectsViewModel

    @State private var name = ""
    @State private var location = ""
    @State private var description = ""
    @State private var workersCount = "10"
    
    @State private var latitude: Double = 6.9271
    @State private var longitude: Double = 79.8612

    private let orange = Color(red: 0.95, green: 0.39, blue: 0.10)

    var body: some View {
        NavigationStack {
            Form {
                Section("Project Details") {
                    TextField("Project Name (e.g. Marina Towers)", text: $name)
                    TextField("Location (e.g. Colombo 03)", text: $location)
                    TextField("Description", text: $description, axis: .vertical)
                    TextField("Workers Assigned", text: $workersCount)
                        .keyboardType(.numberPad)
                }

                Section("GPS Coordinates") {
                    HStack {
                        Text("Latitude")
                        Spacer()
                        TextField("Latitude", text: Binding(
                            get: { String(latitude) },
                            set: { latitude = Double($0) ?? latitude }
                        ))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Longitude")
                        Spacer()
                        TextField("Longitude", text: Binding(
                            get: { String(longitude) },
                            set: { longitude = Double($0) ?? longitude }
                        ))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let workers = Int(workersCount) ?? 5
                        viewModel.addProject(
                            name: name,
                            location: location,
                            description: description,
                            imageName: "building.2.fill",
                            workersAssigned: workers,
                            latitude: latitude,
                            longitude: longitude
                        )
                        dismiss()
                    }
                    .disabled(name.isEmpty || location.isEmpty)
                }
            }
        }
    }
}

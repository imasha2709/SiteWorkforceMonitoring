import SwiftUI
import MapKit

struct ProjectDetailView: View {
    let project: ConstructionProject

    private let orange = Color(red: 0.95, green: 0.39, blue: 0.10)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                
                ZStack(alignment: .bottomLeading) {
                    if let uiImage = UIImage(named: project.imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(orange.opacity(0.15))
                            .frame(height: 220)
                            .overlay {
                                Image(systemName: project.imageName.isEmpty ? "building.2.fill" : project.imageName)
                                    .font(.system(size: 64))
                                    .foregroundStyle(orange)
                            }
                    }

                    LinearGradient(
                        colors: [.clear, .black.opacity(0.6)],
                        startPoint: .center,
                        endPoint: .bottom
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(project.name)
                            .font(.title.bold())
                            .foregroundStyle(.white)

                        Text(project.location)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding()
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))

             
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Project Status")
                            .font(.headline)
                        Spacer()
                        Text(project.status)
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(project.status == "Attention" ? Color.red.opacity(0.15) : Color.green.opacity(0.15))
                            .foregroundStyle(project.status == "Attention" ? .red : .green)
                            .clipShape(Capsule())
                    }

                    Text(project.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Divider()

                    HStack {
                        Text("Overall Progress")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("\(Int(project.progress * 100))%")
                            .bold()
                    }

                    ProgressView(value: project.progress)
                        .tint(orange)

                    Label("\(project.workersAssigned) workers assigned", systemImage: "person.3.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))

          
                VStack(alignment: .leading, spacing: 12) {
                    Text("Milestones & Tasks")
                        .font(.title2.bold())

                    if project.tasks.isEmpty {
                        Text("No tasks assigned yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(project.tasks) { task in
                            HStack(spacing: 12) {
                                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.title3)
                                    .foregroundStyle(task.isCompleted ? .green : .secondary)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(task.title)
                                        .font(.subheadline.weight(.medium))
                                        .strikethrough(task.isCompleted)

                                    Text("Priority: \(task.priority)")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Project Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

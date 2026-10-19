
import SwiftUI

struct DashboardView: View {
    private let model = DashboardViewModel()

    private let orange = Color(
        red: 0.95,
        green: 0.39,
        blue: 0.10
    )

    private let columns = [
        GridItem(.adaptive(minimum: 145), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Site Workforce")
                            .font(.largeTitle.bold())

                        Text("Construction project overview")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Image(systemName: "building.2.fill")
                            .font(.title2)

                        VStack(alignment: .leading) {
                            Text("Main Construction Site")
                                .font(.headline)

                            Text("Site status: Active")
                                .font(.subheadline)
                        }

                        Spacer()

                        Circle()
                            .fill(.green)
                            .frame(width: 12, height: 12)
                    }
                    .padding()
                    .background(orange.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    Text("Today's Overview")
                        .font(.title2.bold())

                    LazyVGrid(columns: columns, spacing: 12) {
                        dashboardCard(
                            title: "Total Workers",
                            value: "\(model.totalWorkers)",
                            icon: "person.3.fill"
                        )

                        dashboardCard(
                            title: "Present Today",
                            value: "\(model.presentWorkers)",
                            icon: "checkmark.circle.fill"
                        )

                        dashboardCard(
                            title: "Active Projects",
                            value: "\(model.activeProjects)",
                            icon: "building.2.fill"
                        )

                        dashboardCard(
                            title: "Pending Tasks",
                            value: "\(model.pendingTasks)",
                            icon: "clock.fill"
                        )
                    }

                    Text("Attendance Summary")
                        .font(.title2.bold())

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Present")
                            Spacer()
                            Text("\(model.presentWorkers)")
                                .bold()
                        }

                        ProgressView(
                            value: Double(model.presentWorkers),
                            total: Double(model.totalWorkers)
                        )
                        .tint(orange)

                        HStack {
                            Text("Absent")
                            Spacer()
                            Text("\(model.absentWorkers)")
                                .bold()
                        }
                    }
                    .padding()
                    .background(
                        Color(.secondarySystemBackground)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
                .frame(maxWidth: 1000)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func dashboardCard(
        title: String,
        value: String,
        icon: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(orange)

            Text(value)
                .font(.largeTitle.bold())

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

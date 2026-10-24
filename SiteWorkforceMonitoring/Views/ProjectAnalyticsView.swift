import SwiftUI
import MapKit

struct ProjectAnalyticsView: View {
    @ObservedObject var viewModel: ProjectsViewModel
    @AppStorage("isDarkModeEnabled") private var isDarkModeEnabled = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("Analytics & Insights")
                        .font(.largeTitle.bold())
                        .foregroundStyle(AppTheme.ink)

                    SurfaceCard {
                        Text("Overall Project Completion")
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)
                        
                        HStack {
                            Text("\(Int(viewModel.averageProgress * 100))%")
                                .font(.system(size: 44, weight: .bold))
                                .foregroundStyle(AppTheme.maroon)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("\(viewModel.projects.count) Active Sites")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(AppTheme.ink)
                                Text("Portfolio Average")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.secondary)
                            }
                        }
                        GradientProgressView(progress: viewModel.averageProgress)
                    }

                    HStack(spacing: 16) {
                        let allTasks = viewModel.projects.flatMap { $0.tasks ?? [] }
                        let completedCount = allTasks.filter { $0.isCompleted }.count
                        let remainingCount = allTasks.count - completedCount

                        taskMetricCard(title: "Completed Tasks", count: "\(completedCount)", color: AppTheme.green)
                        taskMetricCard(title: "Remaining Tasks", count: "\(remainingCount)", color: AppTheme.orange)
                    }

                    SurfaceCard {
                        Text("Weekly Progress Velocity")
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)

                        HStack(alignment: .bottom, spacing: 24) {
                            barView(day: "Mon", height: 40, value: "42%")
                            barView(day: "Tue", height: 60, value: "55%")
                            barView(day: "Wed", height: 75, value: "68%")
                            barView(day: "Thu", height: 65, value: "60%")
                            barView(day: "Fri", height: 90, value: "85%")
                        }
                        .frame(height: 160)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }

                    SurfaceCard {
                        Text("Workforce Attendance Summary")
                            .font(.headline)
                            .foregroundStyle(AppTheme.ink)

                        HStack {
                            Label("Present: 4", systemImage: "checkmark.circle.fill").foregroundStyle(AppTheme.green)
                            Spacer()
                            Label("Late: 1", systemImage: "clock.fill").foregroundStyle(AppTheme.orange)
                            Spacer()
                            Label("Absent: 1", systemImage: "xmark.circle.fill").foregroundStyle(AppTheme.red)
                        }
                        .font(.subheadline.bold())
                        .padding(.top, 4)
                    }
                }
                .padding()
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(isDarkModeEnabled ? .dark : .light)
    }

    private func taskMetricCard(title: String, count: String, color: Color) -> some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(count)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondary)
            }
        }
    }

    private func barView(day: String, height: CGFloat, value: String) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.caption2)
                .foregroundStyle(AppTheme.secondary)

            RoundedRectangle(cornerRadius: 6)
                .fill(AppTheme.progressGradient)
                .frame(width: 32, height: height)

            Text(day)
                .font(.caption.bold())
                .foregroundStyle(AppTheme.ink)
        }
    }
}

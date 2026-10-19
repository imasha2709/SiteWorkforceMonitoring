
import Foundation

struct DashboardViewModel {
    let totalWorkers = 48
    let presentWorkers = 36
    let activeProjects = 4
    let pendingTasks = 7

    var absentWorkers: Int {
        totalWorkers - presentWorkers
    }
}

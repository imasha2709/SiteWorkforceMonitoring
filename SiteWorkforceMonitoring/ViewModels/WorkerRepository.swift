
import Foundation

protocol WorkerRepository {
    func fetchWorkers() async throws -> [Worker]
}

struct SampleWorkerRepository: WorkerRepository {
    func fetchWorkers() async throws -> [Worker] {
        SampleData.workers
    }
}

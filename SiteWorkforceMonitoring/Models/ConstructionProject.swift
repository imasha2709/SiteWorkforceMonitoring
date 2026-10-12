
import Foundation
import CoreLocation

struct ConstructionProject: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let progress: Double
    let status: String
    let workersAssigned: Int
    let coordinate: CLLocationCoordinate2D
}

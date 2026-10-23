import Foundation

struct ConstructionSite: Identifiable {
    var id: String
    var siteId: String
    var projectId: String
    var name: String
    var location: String
    var latitude: Double
    var longitude: Double
    var geofenceRadius: Double
}
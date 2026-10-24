import Foundation
import FirebaseFirestore
import CoreLocation

struct SiteModel: Identifiable, Codable {
    @DocumentID var id: String?
    var siteId: String
    var projectId: String
    var name: String
    var location: String
    var latitude: Double
    var longitude: Double
    var geofenceRadius: Double?

    // Required if you ever map individual sites separately
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case siteId = "siteid"
        case projectId = "projectid"
        case name
        case location
        case latitude
        case longitude
        case geofenceRadius = "geofenceradius"
    }
}

import Foundation
import CoreLocation

enum SampleData {

    static let workers: [Worker] = [
        Worker(
            name: "Kasun Perera",
            role: "Site Supervisor",
            site: "Colombo Tower",
            status: .present,
            initials: "KP"
        ),
        Worker(
            name: "Nimal Fernando",
            role: "Mason",
            site: "Colombo Tower",
            status: .present,
            initials: "NF"
        ),
        Worker(
            name: "Amara Silva",
            role: "Electrician",
            site: "Kandy Road Project",
            status: .late,
            initials: "AS"
        ),
        Worker(
            name: "Dilan Jayawardena",
            role: "Carpenter",
            site: "Colombo Tower",
            status: .present,
            initials: "DJ"
        ),
        Worker(
            name: "Sahan Kumara",
            role: "General Worker",
            site: "Kandy Road Project",
            status: .absent,
            initials: "SK"
        ),
        Worker(
            name: "Tharushi Peris",
            role: "Safety Officer",
            site: "Harbour Extension",
            status: .present,
            initials: "TP"
        )
    ]

    static let projects: [ConstructionProject] = [
        ConstructionProject(
            name: "Colombo Tower",
            location: "Colombo, Sri Lanka",
            progress: 0.68,
            status: "On track",
            workersAssigned: 24,
            coordinate: CLLocationCoordinate2D(
                latitude: 6.9271,
                longitude: 79.8612
            )
        ),
        ConstructionProject(
            name: "Kandy Road Project",
            location: "Kadawatha, Sri Lanka",
            progress: 0.42,
            status: "Attention",
            workersAssigned: 18,
            coordinate: CLLocationCoordinate2D(
                latitude: 7.0015,
                longitude: 79.9543
            )
        ),
        ConstructionProject(
            name: "Harbour Extension",
            location: "Colombo Harbour, Sri Lanka",
            progress: 0.84,
            status: "On track",
            workersAssigned: 31,
            coordinate: CLLocationCoordinate2D(
                latitude: 6.9500,
                longitude: 79.8450
            )
        )
    ]

    static let attendance: [AttendanceRecord] = [
        AttendanceRecord(
            workerName: "Kasun Perera",
            site: "Colombo Tower",
            checkIn: "07:42 AM",
            status: .present
        ),
        AttendanceRecord(
            workerName: "Nimal Fernando",
            site: "Colombo Tower",
            checkIn: "07:51 AM",
            status: .present
        ),
        AttendanceRecord(
            workerName: "Amara Silva",
            site: "Kandy Road Project",
            checkIn: "08:16 AM",
            status: .late
        ),
        AttendanceRecord(
            workerName: "Dilan Jayawardena",
            site: "Colombo Tower",
            checkIn: "07:48 AM",
            status: .present
        ),
        AttendanceRecord(
            workerName: "Sahan Kumara",
            site: "Kandy Road Project",
            checkIn: "—",
            status: .absent
        )
    ]
}

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
            coordinate: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
            progress: 0.68,
            status: "On track",
            workersAssigned: 24,
            imageName: "building.2.fill",
            description: "Commercial skyscraper project in the heart of Colombo.",
            tasks: [
                ProjectTask(title: "Structural framework", isCompleted: true, priority: "High"),
                ProjectTask(title: "Interior plumbing", isCompleted: false, priority: "Normal")
            ]
        ),
        ConstructionProject(
            name: "Kandy Road Project",
            location: "Kadawatha, Sri Lanka",
            coordinate: CLLocationCoordinate2D(latitude: 7.0015, longitude: 79.9543),
            progress: 0.42,
            status: "Attention",
            workersAssigned: 18,
            imageName: "road.lanes",
            description: "Highway expansion and bridge construction.",
            tasks: [
                ProjectTask(title: "Asphalt paving", isCompleted: false, priority: "High"),
                ProjectTask(title: "Drainage system", isCompleted: true, priority: "Normal")
            ]
        ),
        ConstructionProject(
            name: "Harbour Extension",
            location: "Colombo Harbour, Sri Lanka",
            coordinate: CLLocationCoordinate2D(latitude: 6.9500, longitude: 79.8450),
            progress: 0.84,
            status: "On track",
            workersAssigned: 31,
            imageName: "ferry.fill",
            description: "Deep water container terminal expansion.",
            tasks: [
                ProjectTask(title: "Crane rail installation", isCompleted: true, priority: "High"),
                ProjectTask(title: "Dock wall reinforcement", isCompleted: true, priority: "High")
            ]
        ),
        ConstructionProject(
            name: "Skyline Tower A",
            location: "Colombo 02",
            coordinate: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612),
            progress: 0.75,
            status: "On track",
            workersAssigned: 18,
            imageName: "building.2.fill",
            description: "High-rise commercial and residential complex development.",
            tasks: [
                ProjectTask(title: "Foundation pouring & curing", isCompleted: true, priority: "High"),
                ProjectTask(title: "Electrical wiring on level 4", isCompleted: true, priority: "Normal"),
                ProjectTask(title: "Facade glass installation", isCompleted: false, priority: "High"),
                ProjectTask(title: "Safety inspection audit", isCompleted: false, priority: "High")
            ]
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

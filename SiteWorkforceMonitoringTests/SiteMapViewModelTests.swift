import XCTest
import CoreLocation
@testable import SiteWorkforceMonitoring

@MainActor
final class SiteMapViewModelTests: XCTestCase {
    
    var viewModel: SiteMapViewModel!

    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = SiteMapViewModel()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        try super.tearDownWithError()
    }

    func testInitialState() {
        XCTAssertTrue(viewModel.projects.isEmpty)
        XCTAssertTrue(viewModel.attendance.isEmpty)
        XCTAssertNil(viewModel.selectedProjectName)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertEqual(viewModel.selectedStatus, "All")
        XCTAssertNil(viewModel.userLocation)
        XCTAssertTrue(viewModel.routeCoordinates.isEmpty)
        XCTAssertNil(viewModel.travelTime)
        XCTAssertNil(viewModel.distanceText)
        XCTAssertFalse(viewModel.isInsideGeofence)
        XCTAssertEqual(viewModel.geofenceRadiusMeters, 150.0)
    }

    func testSelectedProjectComputedProperty() {
        let project1 = ConstructionProject(
            id: "1",
            projectId: "P001",
            name: "Colombo Tower",
            location: "Colombo 01",
            progress: 0.75,
            status: "Normal",
            managerName: "John Doe",
            imageName: nil,
            description: "High rise commercial building",
            startDate: nil,
            expectedCompletionDate: nil,
            workersAssigned: 10,
            latitude: 6.9271,
            longitude: 79.8612,
            tasks: nil
        )
        
        let project2 = ConstructionProject(
            id: "2",
            projectId: "P002",
            name: "Marina Heights",
            location: "Colombo 03",
            progress: 0.40,
            status: "Attention",
            managerName: "Jane Smith",
            imageName: nil,
            description: "Residential complex",
            startDate: nil,
            expectedCompletionDate: nil,
            workersAssigned: 5,
            latitude: 6.9150,
            longitude: 79.8500,
            tasks: nil
        )

        viewModel.projects = [project1, project2]
        
        viewModel.selectedProjectName = "Marina Heights"
        XCTAssertNotNil(viewModel.selectedProject)
        XCTAssertEqual(viewModel.selectedProject?.name, "Marina Heights")
        XCTAssertEqual(viewModel.selectedProject?.projectId, "P002")

        viewModel.selectedProjectName = "NonExistent Site"
        XCTAssertNil(viewModel.selectedProject)
    }

    func testCurrentSiteWorkerCountWithoutSelection() {
        let project1 = ConstructionProject(
            id: "1", projectId: "P001", name: "Site A", location: nil, progress: 0.5,
            status: "Normal", managerName: "Manager A", imageName: nil, description: nil,
            startDate: nil, expectedCompletionDate: nil, workersAssigned: 12,
            latitude: 0, longitude: 0, tasks: nil
        )
        let project2 = ConstructionProject(
            id: "2", projectId: "P002", name: "Site B", location: nil, progress: 0.5,
            status: "Normal", managerName: "Manager B", imageName: nil, description: nil,
            startDate: nil, expectedCompletionDate: nil, workersAssigned: 8,
            latitude: 0, longitude: 0, tasks: nil
        )

        viewModel.projects = [project1, project2]
        viewModel.selectedProjectName = nil

        XCTAssertEqual(viewModel.currentSiteWorkerCount, 20)
    }

    func testAttendanceFilteringByStatusAndSearch() {
        let record1 = AttendanceRecord(id: "1", workerName: "Kamal Silva", siteId: "Colombo Tower", status: .present, checkIn: nil)
        let record2 = AttendanceRecord(id: "2", workerName: "Nimal Perera", siteId: "Marina Heights", status: .late, checkIn: nil)
        
        viewModel.attendance = [record1, record2]
        
        // Test status filter
        viewModel.selectedStatus = "Late"
        XCTAssertEqual(viewModel.filteredAttendance.count, 1)
        XCTAssertEqual(viewModel.filteredAttendance.first?.workerName, "Nimal Perera")

        // Test search filter
        viewModel.selectedStatus = "All"
        viewModel.searchText = "Kamal"
        XCTAssertEqual(viewModel.filteredAttendance.count, 1)
        XCTAssertEqual(viewModel.filteredAttendance.first?.workerName, "Kamal Silva")
    }
}

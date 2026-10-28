import XCTest
import Combine
@testable import SiteWorkforceMonitoring

@MainActor
final class DashboardViewModelTests: XCTestCase {
    
    var viewModel: DashboardViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = DashboardViewModel()
        cancellables = []
    }

    override func tearDownWithError() throws {
        viewModel = nil
        cancellables = nil
        try super.tearDownWithError()
    }

    func testInitialDashboardState() {
        XCTAssertEqual(viewModel.totalWorkers, 0, "Initial total workers should be 0")
        XCTAssertEqual(viewModel.presentWorkers, 0, "Initial present workers should be 0")
        XCTAssertEqual(viewModel.absentWorkers, 0, "Initial absent workers should be 0")
        XCTAssertEqual(viewModel.activeProjects, 0, "Initial active projects should be 0")
        XCTAssertEqual(viewModel.pendingTasks, 0, "Initial pending tasks should be 0")
        XCTAssertTrue(viewModel.alerts.isEmpty, "Initial alerts list should be empty")
    }

 
    func testSiteAlertInitialization() {
        let alert = SiteAlert(
            title: "Safety Warning",
            message: "Helmet required in sector B",
            severity: "Critical",
            type: "Safety",
            projectId: "PROJ-1234",
            isRead: false,
            createdAt: nil
        )

        XCTAssertEqual(alert.title, "Safety Warning")
        XCTAssertEqual(alert.message, "Helmet required in sector B")
        XCTAssertEqual(alert.severity, "Critical")
        XCTAssertEqual(alert.type, "Safety")
        XCTAssertEqual(alert.projectId, "PROJ-1234")
        XCTAssertFalse(alert.isRead)
    }

    
    func testLocalNotificationContentGeneration() {
        let alert = SiteAlert(
            title: "Geofence Entry",
            message: "Manager entered Main Site boundary",
            severity: "Warning",
            type: "Geofence",
            isRead: false
        )

  
        let expectation = XCTestExpectation(description: "Trigger local notification call completes")
        
        DispatchQueue.main.async {
            self.viewModel.triggerLocalPushNotification(for: alert)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}

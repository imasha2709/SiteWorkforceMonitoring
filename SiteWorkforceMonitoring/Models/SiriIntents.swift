import AppIntents

// MARK: - 1. Check Project Progress Intent
struct CheckProjectProgressIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Project Progress"
    static var description = IntentDescription("Checks the overall completion progress of your construction projects.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let responseMessage = "Your active construction projects are currently on track."
        return .result(dialog: IntentDialog(stringLiteral: responseMessage))
    }
}

// MARK: - 2. Check Attendance Intent
struct CheckAttendanceIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Workforce Attendance"
    static var description = IntentDescription("Check how many workers are present today.")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let presentCount = 4
        let message = "There are \(presentCount) workers marked present today across your active sites."
        return .result(dialog: IntentDialog(stringLiteral: message))
    }
}

// MARK: - 3. Unified App Shortcuts Provider
struct ConstructionAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        // Project Progress Shortcut
        AppShortcut(
            intent: CheckProjectProgressIntent(),
            phrases: [
                "Check project progress in \(.applicationName)",
                "What is the status of projects using \(.applicationName)"
            ],
            shortTitle: "Project Progress",
            systemImageName: "building.2.fill"
        )
        
        // Workforce Attendance Shortcut
        AppShortcut(
            intent: CheckAttendanceIntent(),
            phrases: [
                "How many workers are present in \(.applicationName)",
                "Check attendance in \(.applicationName)"
            ],
            shortTitle: "Worker Attendance",
            systemImageName: "person.3.fill"
        )
    }
}

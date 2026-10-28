import SwiftUI
import Combine
import FirebaseFirestore
import CoreLocation
import UserNotifications

struct SiteAlert: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var message: String
    var severity: String
    var type: String
    var projectId: String?
    var isRead: Bool
    var createdAt: Timestamp?
    
    enum CodingKeys: String, CodingKey {
        case id, title, message, severity, type, projectId, isRead, createdAt
    }
}

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var totalWorkers: Int = 0
    @Published var presentWorkers: Int = 0
    @Published var absentWorkers: Int = 0
    @Published var activeProjects: Int = 0
    @Published var pendingTasks: Int = 0
    @Published var alerts: [SiteAlert] = []
    
    private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []
    private var notifiedAlertIds: Set<String> = []

    init() {
        requestNotificationPermission()
        setupListeners()
    }

    deinit {
        listeners.forEach { $0.remove() }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Notification Permission Error: \(error.localizedDescription)")
            } else {
                print("🔔 Local Push Notifications Authorized: \(granted)")
            }
        }
    }

    private func setupListeners() {
        let workerListener = db.collection("workers").addSnapshotListener { [weak self] snapshot, _ in
            guard let self = self, let docs = snapshot?.documents else { return }
            self.totalWorkers = docs.count
            let presentCount = docs.filter { doc in
                let status = doc.data()["status"] as? String ?? ""
                return status.lowercased() == "present"
            }.count
            self.presentWorkers = presentCount > 0 ? presentCount : Int(Double(docs.count) * 0.8)
            self.absentWorkers = max(0, self.totalWorkers - self.presentWorkers)
        }
        
        let projectListener = db.collection("projects").addSnapshotListener { [weak self] snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            self?.activeProjects = docs.count
        }
        
        let taskListener = db.collection("tasks").addSnapshotListener { [weak self] snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            self?.pendingTasks = docs.filter { doc in
                let isCompleted = doc.data()["completes"] as? Bool ?? doc.data()["isCompleted"] as? Bool ?? false
                return !isCompleted
            }.count
        }

        let alertListener = db.collection("alerts")
            .order(by: "createdAt", descending: true)
            .limit(to: 5)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error fetching alerts: \(error.localizedDescription)")
                    return
                }
                guard let snapshot = snapshot else { return }
                
                self?.alerts = snapshot.documents.compactMap { doc in
                    try? doc.data(as: SiteAlert.self)
                }

               
                for change in snapshot.documentChanges {
                    if change.type == .added {
                        if let alert = try? change.document.data(as: SiteAlert.self) {
                            let alertId = alert.id ?? UUID().uuidString
                            if !(self?.notifiedAlertIds.contains(alertId) ?? false) {
                                self?.notifiedAlertIds.insert(alertId)
                                self?.triggerLocalPushNotification(for: alert)
                            }
                        }
                    }
                }
            }

        listeners = [workerListener, projectListener, taskListener, alertListener]
    }
    
    func createNewAlert(title: String, message: String, severity: String, type: String) {
        let newAlertData: [String: Any] = [
            "title": title,
            "message": message,
            "severity": severity,
            "type": type,
            "isRead": false,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("alerts").addDocument(data: newAlertData)
    }

    func triggerLocalPushNotification(for alert: SiteAlert) {
        let content = UNMutableNotificationContent()
        content.title = "[\(alert.severity.uppercased())] \(alert.title)"
        content.body = alert.message
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: alert.id ?? UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print(" Failed to post local push notification: \(error.localizedDescription)")
            } else {
                print("Local push notification scheduled successfully!")
            }
        }
    }
    
    func createNewWorker(name: String, role: String, siteId: String, status: AttendanceStatus) {
        let workerData: [String: Any] = [
            "name": name,
            "role": role,
            "siteid": siteId,
            "status": status.rawValue
        ]
        db.collection("workers").addDocument(data: workerData)
    }
    
    func createNewProject(name: String, managerName: String, location: String, status: String, workersAssigned: Int, startDate: Date, expectedCompletionDate: Date, progress: Double) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let projectData: [String: Any] = [
            "projectId": "PROJ-\(Int.random(in: 1000...9999))",
            "name": name,
            "managerName": managerName,
            "location": location,
            "status": status,
            "workersAssigned": workersAssigned,
            "startDate": formatter.string(from: startDate),
            "expectedCompletionDate": formatter.string(from: expectedCompletionDate),
            "progress": progress
        ]
        db.collection("projects").addDocument(data: projectData)
    }
}

struct DashboardView: View {
    @StateObject private var model = DashboardViewModel()
    
    @State private var showingAddWorker = false
    @State private var showingAddProject = false

    private let orange = Color(red: 0.95, green: 0.39, blue: 0.10)
    private let columns = [
        GridItem(.adaptive(minimum: 145), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Site Workforce")
                            .font(.largeTitle.bold())
                        Text("Construction project overview & real-time monitoring")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Image(systemName: "building.2.fill")
                            .font(.title2)
                            .foregroundStyle(orange)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Main Construction Site")
                                .font(.headline)
                            Text("Site status: Active • Geofencing Enabled")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Circle()
                            .fill(.green)
                            .frame(width: 12, height: 12)
                    }
                    .padding()
                    .background(orange.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick Actions")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            Button {
                                showingAddWorker = true
                            } label: {
                                Label("Add Worker", systemImage: "person.badge.plus")
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(orange)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)

                            Button {
                                showingAddProject = true
                            } label: {
                                Label("Add Project", systemImage: "folder.badge.plus")
                                    .font(.subheadline.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(orange.opacity(0.15))
                                    .foregroundStyle(orange)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if !model.alerts.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Site Alerts & Warnings")
                                    .font(.title2.bold())
                                Spacer()
                                NavigationLink {
                                    AlertsDetailView(viewModel: model)
                                } label: {
                                    Text("See All (\(model.alerts.count))")
                                        .font(.subheadline.bold())
                                        .foregroundStyle(orange)
                                }
                            }

                            ForEach(model.alerts) { alert in
                                NavigationLink {
                                    AlertsDetailView(viewModel: model)
                                } label: {
                                    alertCard(alert)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Text("Today's Overview")
                        .font(.title2.bold())

                    LazyVGrid(columns: columns, spacing: 12) {
                        dashboardCard(title: "Total Workers", value: "\(model.totalWorkers)", icon: "person.3.fill")
                        dashboardCard(title: "Present Today", value: "\(model.presentWorkers)", icon: "checkmark.circle.fill")
                        dashboardCard(title: "Active Projects", value: "\(model.activeProjects)", icon: "building.2.fill")
                        dashboardCard(title: "Pending Tasks", value: "\(model.pendingTasks)", icon: "clock.fill")
                    }

                    Text("Attendance Summary")
                        .font(.title2.bold())

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Present Attendance Ratio")
                            Spacer()
                            Text("\(model.presentWorkers) / \(model.totalWorkers)")
                                .bold()
                        }

                        ProgressView(
                            value: Double(model.presentWorkers),
                            total: max(Double(model.totalWorkers), 1.0)
                        )
                        .tint(orange)

                        HStack {
                            Text("Absent / Off-site")
                            Spacer()
                            Text("\(model.absentWorkers)")
                                .bold()
                                .foregroundStyle(.red)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
                .frame(maxWidth: 1000)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddWorker) {
                AddWorkerView(viewModel: model)
            }
            .sheet(isPresented: $showingAddProject) {
                AddProjectView(viewModel: model)
            }
        }
    }

    private func dashboardCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(orange)

            Text(value)
                .font(.largeTitle.bold())

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func alertCard(_ alert: SiteAlert) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: alert.severity.lowercased() == "critical" ? "exclamationmark.octagon.fill" : "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundStyle(alert.severity.lowercased() == "critical" ? .red : orange)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(alert.title)
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                    Spacer()
                    Text(alert.severity)
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background((alert.severity.lowercased() == "critical" ? Color.red : Color.orange).opacity(0.15))
                        .foregroundStyle(alert.severity.lowercased() == "critical" ? .red : orange)
                        .clipShape(Capsule())
                }

                Text(alert.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if let timestamp = alert.createdAt {
                    Text(timestamp.dateValue().formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.top, 2)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct AlertsDetailView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var showingAddAlert = false

    private let orange = Color(red: 0.95, green: 0.39, blue: 0.10)

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Logged Warnings & Alerts")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    showingAddAlert = true
                } label: {
                    Label("Log New Alert", systemImage: "plus.circle.fill")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(orange)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))

            List {
                ForEach(viewModel.alerts) { alert in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(alert.title)
                                .font(.headline)
                            Spacer()
                            Text(alert.severity)
                                .font(.caption.bold())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background((alert.severity.lowercased() == "critical" ? Color.red : Color.orange).opacity(0.15))
                                .foregroundStyle(alert.severity.lowercased() == "critical" ? .red : orange)
                                .clipShape(Capsule())
                        }
                        Text(alert.message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        if let timestamp = alert.createdAt {
                            Text(timestamp.dateValue().formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Site Alerts")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddAlert) {
            AddAlertModalView(viewModel: viewModel)
        }
    }
}

struct AddAlertModalView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var message = ""
    @State private var severity = "Warning"
    @State private var type = "Attendance"

    let severities = ["Info", "Warning", "Critical"]
    let types = ["Attendance", "Geofence", "Safety", "Task"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Alert Details") {
                    TextField("Title", text: $title)
                    TextField("Message Description", text: $message)
                    Picker("Severity", selection: $severity) {
                        ForEach(severities, id: \.self) { Text($0) }
                    }
                    Picker("Category Type", selection: $type) {
                        ForEach(types, id: \.self) { Text($0) }
                    }
                }
            }
            .navigationTitle("Log New Alert")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.createNewAlert(title: title, message: message, severity: severity, type: type)
                        dismiss()
                    }
                    .disabled(title.isEmpty || message.isEmpty)
                }
            }
        }
    }
}

struct AddWorkerView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var role = "Electrician"
    @State private var siteId = "SITE-01"
    @State private var status: AttendanceStatus = .present

    let roles = ["Electrician", "Civil Engineer", "Safety Inspector", "Plumber", "Mason", "Site Supervisor", "General Laborer"]
    let sites = ["SITE-01", "SITE-02", "SITE-03"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Worker Information") {
                    TextField("Full Name", text: $name)
                    
                    Picker("Role / Trade", selection: $role) {
                        ForEach(roles, id: \.self) { roleName in
                            Text(roleName).tag(roleName)
                        }
                    }
                    
                    Picker("Assigned Site", selection: $siteId) {
                        ForEach(sites, id: \.self) { site in
                            Text(site).tag(site)
                        }
                    }
                }
                
                Section("Initial Attendance Status") {
                    Picker("Status", selection: $status) {
                        ForEach(AttendanceStatus.allCases, id: \.self) { statusItem in
                            Text(statusItem.rawValue).tag(statusItem)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("New Worker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.createNewWorker(name: name, role: role, siteId: siteId, status: status)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct AddProjectView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.dismiss) var dismiss

    @State private var projectName = ""
    @State private var managerName = ""
    @State private var location = ""
    @State private var status = "In Progress"
    @State private var workersAssigned = 10
    @State private var progress: Double = 0.0
    @State private var startDate = Date()
    @State private var expectedCompletionDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()

    let statuses = ["Planned", "In Progress", "On Hold", "Completed"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Project Details") {
                    TextField("Project Name", text: $projectName)
                    TextField("Manager Name", text: $managerName)
                    TextField("Location / Address", text: $location)
                    
                    Picker("Status", selection: $status) {
                        ForEach(statuses, id: \.self) { statusItem in
                            Text(statusItem).tag(statusItem)
                        }
                    }
                }
                
                Section("Resource Allocation") {
                    Stepper("Assigned Workers: \(workersAssigned)", value: $workersAssigned, in: 1...500)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Initial Progress")
                            Spacer()
                            Text("\(Int(progress * 100))%")
                                .bold()
                        }
                        Slider(value: $progress, in: 0.0...1.0)
                    }
                }
                
                Section("Timeline") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("Expected Completion", selection: $expectedCompletionDate, in: startDate..., displayedComponents: .date)
                }
            }
            .navigationTitle("New Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.createNewProject(
                            name: projectName,
                            managerName: managerName,
                            location: location,
                            status: status,
                            workersAssigned: workersAssigned,
                            startDate: startDate,
                            expectedCompletionDate: expectedCompletionDate,
                            progress: progress
                        )
                        dismiss()
                    }
                    .disabled(projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || managerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

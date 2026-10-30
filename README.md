# Site Workforce & Project Monitoring

## 1. Project Overview

Site Workforce & Project Monitoring is an iOS application designed for construction site supervisors and project managers to manage workforce activities and monitor project progress in one place.

### Main Features
- Splash screen and three-screen onboarding.
- User registration and login.
- Dashboard with workforce and project summaries.
- Worker management.
- Attendance management.
- Construction project monitoring.
- Site map using MapKit.
- Face ID authentication.
- Push notifications (where configured).
- User profile and settings.

## 2. Technologies Used

- **Swift & SwiftUI** – iOS development.
- **Firebase Authentication** – User authentication.
- **Cloud Firestore** – Cloud database.
- **MapKit & Core Location** – Site locations and location functionality.
- **LocalAuthentication** – Biometric authentication.
- **UserNotifications** – Notifications.
- **Git & GitHub** – Version control.

## 3. Requirements

- macOS and Xcode.
- iOS Simulator or a compatible iPhone.
- Internet connection.
- Access to the Firebase project.

## 4. How to Run the Application

1. Clone the repository:

```bash
git clone [https://github.com/imasha2709/SiteWorkforceMonitoring.git]
```

2. Open the `.xcodeproj` or `.xcworkspace` file in Xcode.
3. Ensure `GoogleService-Info.plist` is added to the application target.
4. Select an iOS Simulator or connected iPhone.
5. Build and run using **Command + R**.

## 5. Firebase Backend Setup

The application uses Firebase as its cloud backend. A separate Node.js or Express server is not required.

1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Select the existing Firebase project.
3. Register the iOS app using the correct bundle identifier if setting up a new Firebase project.
4. Download and add `GoogleService-Info.plist` to the Xcode project.
5. Enable the required sign-in methods under **Authentication**.
6. Create or select a **Cloud Firestore** database.
7. Configure appropriate Firestore security rules.

Firebase provides cloud authentication and database services directly to the iOS application.

## 6. Troubleshooting

| Issue | Solution |
|---|---|
| Application build fails | Check Xcode errors and dependencies. |
| Firebase connection fails | Verify Firebase configuration and bundle ID. |
| Data is not saved | Check Firestore rules and database operations. |
| Map does not load | Check MapKit and location configuration. |
| Face ID fails | Check device compatibility and authentication settings. |
| Notifications do not arrive | Check notification permissions and APNs configuration. |

## 7. Author

**Project:** Site Workforce & Project Monitoring  
**Platform:** iOS  
**Development Environment:** Xcode  
**Repository:** https://github.com/imasha2709/SiteWorkforceMonitoring.git

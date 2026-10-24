import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @EnvironmentObject var authentication: AuthenticationViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isSigningUp = false
    @State private var isPasswordVisible = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "building.2.crop.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.orange)
                            .shadow(radius: 4)

                        Text("Site Workforce")
                            .font(.largeTitle.bold())

                        Text(isSigningUp ? "Create your Project Manager account" : "Sign in to manage your sites")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)

                    VStack(spacing: 16) {
                        if isSigningUp {
                            TextField("Full Name", text: $name)
                                .textContentType(.name)
                                .autocapitalization(.words)
                                .padding()
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        TextField("Email Address", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                        HStack {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                                    .textContentType(isSigningUp ? .newPassword : .password)
                                    .autocapitalization(.none)
                            } else {
                                SecureField("Password", text: $password)
                                    .textContentType(isSigningUp ? .newPassword : .password)
                            }

                            Button {
                                isPasswordVisible.toggle()
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)

                    if !isSigningUp {
                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                handleForgotPassword()
                            }
                            .font(.footnote.bold())
                            .foregroundStyle(.orange)
                        }
                        .padding(.horizontal)
                    }

                    Button {
                        handleAuthentication()
                    } label: {
                        Text(isSigningUp ? "Create Account" : "Sign In")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .orange.opacity(0.3), radius: 6, x: 0, y: 4)
                    }
                    .padding(.horizontal)

                    if !isSigningUp {
                        Button {
                            authenticateWithFaceID()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "faceid")
                                    .font(.title2)
                                Text("Sign in with Face ID")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal)
                    }

                    Button {
                        isSigningUp.toggle()
                        alertMessage = ""
                    } label: {
                        HStack {
                            Text(isSigningUp ? "Already have an account?" : "Don't have an account?")
                                .foregroundStyle(.secondary)
                            Text(isSigningUp ? "Sign In" : "Sign Up")
                                .bold()
                                .foregroundStyle(.orange)
                        }
                        .font(.subheadline)
                    }
                    .padding(.top, 10)
                }
                .padding()
                .frame(maxWidth: 450)
                .frame(maxWidth: .infinity)
            }
            .alert("Notice", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func handleAuthentication() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in both email and password fields."
            showAlert = true
            return
        }
        
        if isSigningUp {
            guard !name.isEmpty else {
                alertMessage = "Please enter your full name."
                showAlert = true
                return
            }
            
            authentication.signUp(email: email, password: password, name: name, role: .projectManager) { error in
                if let error = error {
                    alertMessage = error
                    showAlert = true
                } else {
                    alertMessage = "Account created successfully!"
                    showAlert = true
                }
            }
        } else {
            authentication.signIn(email: email, password: password) { error in
                if let error = error {
                    alertMessage = error
                    showAlert = true
                } else {
                    alertMessage = "Signed in successfully!"
                    showAlert = true
                }
            }
        }
    }

    private func handleForgotPassword() {
        guard !email.isEmpty else {
            alertMessage = "Please enter your email address above first, then tap 'Forgot Password?'."
            showAlert = true
            return
        }
        
        authentication.resetPassword(email: email) { message in
            alertMessage = message
            showAlert = true
        }
    }

    private func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Log in to Site Workforce using your biometric data."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        alertMessage = "Face ID verified successfully!"
                        showAlert = true
                    } else {
                        alertMessage = "Face ID authentication failed."
                        showAlert = true
                    }
                }
            }
        } else {
            alertMessage = "Biometric authentication is not available on this device."
            showAlert = true
        }
    }
}

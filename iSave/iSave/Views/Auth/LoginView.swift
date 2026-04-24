import SwiftUI

struct LoginView: View {

    @EnvironmentObject private var authVM: AuthViewModel

    @State private var email    = ""
    @State private var password = ""
    @State private var name     = ""
    @State private var isRegistering = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    // Logo / heading
                    VStack(spacing: 8) {
                        Image(systemName: "banknote.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.blue)
                        Text("iSave")
                            .font(.largeTitle.bold())
                        Text(isRegistering ? "Create your account" : "Welcome back")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 48)

                    // Form
                    VStack(spacing: 16) {
                        if isRegistering {
                            Field("Full name", text: $name, icon: "person")
                        }

                        Field("Email", text: $email, icon: "envelope")
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()

                        Field("Password", text: $password, icon: "lock", isSecure: true)
                    }
                    .padding(.horizontal, 24)

                    // Error
                    if let msg = authVM.errorMessage {
                        Text(msg)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Primary action
                    Button {
                        Task {
                            if isRegistering {
                                await authVM.register(email: email, password: password, name: name)
                            } else {
                                await authVM.login(email: email, password: password)
                            }
                        }
                    } label: {
                        Group {
                            if authVM.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(isRegistering ? "Create account" : "Sign in")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(authVM.isLoading || email.isEmpty || password.isEmpty)
                    .padding(.horizontal, 24)

                    // Toggle register/login
                    Button {
                        withAnimation { isRegistering.toggle() }
                        authVM.errorMessage = nil
                    } label: {
                        Text(isRegistering
                             ? "Already have an account? **Sign in**"
                             : "Don't have an account? **Create one**")
                            .font(.footnote)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Helpers

private struct Field: View {
    let label: String
    @Binding var text: String
    let icon: String
    var isSecure = false

    init(_ label: String, text: Binding<String>, icon: String, isSecure: Bool = false) {
        self.label    = label
        self._text    = text
        self.icon     = icon
        self.isSecure = isSecure
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            if isSecure {
                SecureField(label, text: $text)
            } else {
                TextField(label, text: $text)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 50)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel(api: APIService()))
}

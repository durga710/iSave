import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    var isAuthenticated: Bool { currentUser != nil }

    private let api: APIService

    init(api: APIService) {
        self.api = api
    }

    // Restore session from Keychain on cold launch
    func restoreSession() async {
        guard KeychainHelper.read(forKey: KeychainHelper.jwtKey) != nil else { return }
        do {
            currentUser = try await api.me()
        } catch {
            // Token is stale — clear it so the login screen is shown
            KeychainHelper.delete(forKey: KeychainHelper.jwtKey)
        }
    }

    func register(email: String, password: String, name: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let response = try await api.register(email: email, password: password, name: name)
            KeychainHelper.save(response.token, forKey: KeychainHelper.jwtKey)
            currentUser = response.user
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let response = try await api.login(email: email, password: password)
            KeychainHelper.save(response.token, forKey: KeychainHelper.jwtKey)
            currentUser = response.user
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        KeychainHelper.delete(forKey: KeychainHelper.jwtKey)
        currentUser = nil
    }
}

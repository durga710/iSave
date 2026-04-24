import Foundation
import Combine

@MainActor
final class UserPreferencesViewModel: ObservableObject {

    @Published var preferences: UserPreferences = .default
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let api: APIService

    init(api: APIService) {
        self.api = api
    }

    // MARK: - Read

    func loadPreferences() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            preferences = try await api.fetchPreferences()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Write

    func savePreferences() async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            preferences = try await api.savePreferences(preferences)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Convenience setters that auto-save
    func setMonthlyIncome(_ value: Double) async {
        preferences.monthlyIncome = value
        await savePreferences()
    }

    func setExtraPayment(_ value: Double) async {
        preferences.extraPayment = value
        await savePreferences()
    }

    func setPayoffStrategy(_ strategy: String) async {
        preferences.payoffStrategy = strategy
        await savePreferences()
    }

    func setNotificationsEnabled(_ enabled: Bool) async {
        preferences.notificationsEnabled = enabled
        await savePreferences()
    }
}

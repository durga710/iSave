import SwiftUI

@main
struct iSaveApp: App {

    // Shared API client — one instance for the entire app
    private let api = APIService()

    // Auth state — drives the login gate
    @StateObject private var authVM: AuthViewModel

    // Data ViewModels — created once, passed down via environmentObject
    @StateObject private var cardVM: CreditCardViewModel
    @StateObject private var txVM: TransactionViewModel
    @StateObject private var catVM: CategoryViewModel
    @StateObject private var prefsVM: UserPreferencesViewModel
    @StateObject private var plaidManager: PlaidManager

    init() {
        let api = APIService()
        _authVM      = StateObject(wrappedValue: AuthViewModel(api: api))
        _cardVM      = StateObject(wrappedValue: CreditCardViewModel(api: api))
        _txVM        = StateObject(wrappedValue: TransactionViewModel(api: api))
        _catVM       = StateObject(wrappedValue: CategoryViewModel(api: api))
        _prefsVM     = StateObject(wrappedValue: UserPreferencesViewModel(api: api))
        _plaidManager = StateObject(wrappedValue: PlaidManager(api: api))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isAuthenticated {
                    ContentView()
                        .environmentObject(cardVM)
                        .environmentObject(txVM)
                        .environmentObject(catVM)
                        .environmentObject(prefsVM)
                        .environmentObject(plaidManager)
                        .environmentObject(authVM)
                        .task {
                            // Load data in parallel after login
                            async let cards   = cardVM.loadCards()
                            async let tx      = txVM.loadAll()
                            async let cats    = catVM.loadCategories()
                            async let prefs   = prefsVM.loadPreferences()
                            _ = await (cards, tx, cats, prefs)
                        }
                } else {
                    LoginView()
                        .environmentObject(authVM)
                }
            }
            .task {
                // Try to restore session from saved JWT
                await authVM.restoreSession()
            }
        }
    }
}

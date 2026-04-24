import Foundation

// MARK: - APIService

final class APIService: ObservableObject {

    // Replace with your deployed backend URL (no trailing slash)
    static let baseURL = ProcessInfo.processInfo.environment["API_BASE_URL"]
        ?? "http://localhost:3000"

    // JWT is read fresh from Keychain on each request so any in-flight
    // request picks up a refreshed token without needing a callback.
    private var token: String? { KeychainHelper.read(forKey: KeychainHelper.jwtKey) }

    // ─── Generic request helper ──────────────────────────────────────────────

    @discardableResult
    func request<T: Decodable>(
        _ path: String,
        method: String = "GET",
        body: [String: Any]? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(APIService.baseURL)\(path)") else {
            throw URLError(.badURL)
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        if !(200..<300).contains(http.statusCode) {
            let msg = (try? JSONDecoder().decode(APIError.self, from: data))?.error
                ?? "HTTP \(http.statusCode)"
            throw NSError(domain: "APIService", code: http.statusCode,
                          userInfo: [NSLocalizedDescriptionKey: msg])
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    // ─── Auth ─────────────────────────────────────────────────────────────────

    func register(email: String, password: String, name: String) async throws -> AuthResponse {
        try await request("/auth/register", method: "POST",
                          body: ["email": email, "password": password, "name": name])
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        try await request("/auth/login", method: "POST",
                          body: ["email": email, "password": password])
    }

    func me() async throws -> User {
        try await request("/auth/me")
    }

    // ─── Credit Cards ─────────────────────────────────────────────────────────

    func fetchCards() async throws -> [CreditCard] {
        try await request("/cards")
    }

    func createCard(_ card: CreditCard) async throws -> CreditCard {
        try await request("/cards", method: "POST", body: cardBody(card))
    }

    func updateCard(_ card: CreditCard) async throws -> CreditCard {
        try await request("/cards/\(card.id)", method: "PUT", body: cardBody(card))
    }

    func deleteCard(id: String) async throws {
        struct Empty: Decodable {}
        let _: Empty = try await request("/cards/\(id)", method: "DELETE")
    }

    private func cardBody(_ c: CreditCard) -> [String: Any] {
        [
            "name":            c.name,
            "balance":         c.balance,
            "credit_limit":    c.creditLimit,
            "apr":             c.apr,
            "minimum_payment": c.minimumPayment,
            "card_type":       c.cardType,
            "color":           c.color,
        ]
    }

    // ─── Transactions ─────────────────────────────────────────────────────────

    func fetchTransactions(cardId: String? = nil, limit: Int = 100) async throws -> [Transaction] {
        var path = "/transactions?limit=\(limit)"
        if let cardId { path += "&card_id=\(cardId)" }
        return try await request(path)
    }

    func createTransaction(_ tx: Transaction) async throws -> Transaction {
        try await request("/transactions", method: "POST", body: txBody(tx))
    }

    func updateTransaction(_ tx: Transaction) async throws -> Transaction {
        try await request("/transactions/\(tx.id)", method: "PUT", body: txBody(tx))
    }

    func deleteTransaction(id: String) async throws {
        struct Empty: Decodable {}
        let _: Empty = try await request("/transactions/\(id)", method: "DELETE")
    }

    private func txBody(_ t: Transaction) -> [String: Any] {
        [
            "credit_card_id": t.creditCardId,
            "amount":         t.amount,
            "description":    t.description,
            "category":       t.category,
            "date":           t.date,
            "is_pending":     t.isPending,
        ]
    }

    // ─── Budget Categories ────────────────────────────────────────────────────

    func fetchCategories() async throws -> [BudgetCategory] {
        try await request("/categories")
    }

    func createCategory(_ cat: BudgetCategory) async throws -> BudgetCategory {
        try await request("/categories", method: "POST", body: catBody(cat))
    }

    func updateCategory(_ cat: BudgetCategory) async throws -> BudgetCategory {
        try await request("/categories/\(cat.id)", method: "PUT", body: catBody(cat))
    }

    func deleteCategory(id: String) async throws {
        struct Empty: Decodable {}
        let _: Empty = try await request("/categories/\(id)", method: "DELETE")
    }

    private func catBody(_ c: BudgetCategory) -> [String: Any] {
        ["name": c.name, "budget_amount": c.budgetAmount, "color": c.color, "icon": c.icon]
    }

    // ─── User Preferences ─────────────────────────────────────────────────────

    func fetchPreferences() async throws -> UserPreferences {
        try await request("/preferences")
    }

    func savePreferences(_ prefs: UserPreferences) async throws -> UserPreferences {
        try await request("/preferences", method: "PUT", body: [
            "monthly_income":        prefs.monthlyIncome,
            "extra_payment":         prefs.extraPayment,
            "payoff_strategy":       prefs.payoffStrategy,
            "notifications_enabled": prefs.notificationsEnabled,
        ])
    }

    // ─── Plaid ────────────────────────────────────────────────────────────────

    func createPlaidLinkToken() async throws -> String {
        let res: PlaidLinkTokenResponse = try await request("/plaid/create-link-token", method: "POST")
        return res.linkToken
    }

    func exchangePlaidToken(publicToken: String, institutionName: String) async throws -> PlaidExchangeResponse {
        try await request("/plaid/exchange-token", method: "POST", body: [
            "public_token":    publicToken,
            "institution_name": institutionName,
        ])
    }

    func syncPlaid() async throws -> PlaidExchangeResponse {
        try await request("/plaid/sync", method: "POST")
    }
}

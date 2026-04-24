import Foundation

// MARK: - User

struct User: Codable, Equatable {
    let id: String
    let email: String
    let name: String?
}

struct AuthResponse: Codable {
    let token: String
    let user: User
}

// MARK: - Credit Card

struct CreditCard: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var balance: Double
    var creditLimit: Double
    var apr: Double
    var minimumPayment: Double
    var cardType: String
    var color: String
    var plaidAccountId: String?

    enum CodingKeys: String, CodingKey {
        case id, name, balance, apr, color
        case creditLimit     = "credit_limit"
        case minimumPayment  = "minimum_payment"
        case cardType        = "card_type"
        case plaidAccountId  = "plaid_account_id"
    }

    // Convenience: utilisation ratio 0–1
    var utilization: Double {
        guard creditLimit > 0 else { return 0 }
        return min(balance / creditLimit, 1.0)
    }

    // Available credit
    var availableCredit: Double {
        max(creditLimit - balance, 0)
    }
}

// MARK: - Transaction

struct Transaction: Identifiable, Codable, Equatable {
    let id: String
    var creditCardId: String
    var amount: Double
    var description: String
    var category: String
    var date: String          // "YYYY-MM-DD" from backend
    var isPending: Bool
    var plaidTransactionId: String?

    enum CodingKeys: String, CodingKey {
        case id, amount, description, category, date
        case creditCardId          = "credit_card_id"
        case isPending             = "is_pending"
        case plaidTransactionId    = "plaid_transaction_id"
    }

    var parsedDate: Date {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.date(from: date) ?? Date()
    }
}

// MARK: - Budget Category

struct BudgetCategory: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var budgetAmount: Double
    var color: String
    var icon: String

    enum CodingKeys: String, CodingKey {
        case id, name, color, icon
        case budgetAmount = "budget_amount"
    }
}

// MARK: - User Preferences

struct UserPreferences: Codable, Equatable {
    var monthlyIncome: Double
    var extraPayment: Double
    var payoffStrategy: String      // "avalanche" or "snowball"
    var notificationsEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case monthlyIncome        = "monthly_income"
        case extraPayment         = "extra_payment"
        case payoffStrategy       = "payoff_strategy"
        case notificationsEnabled = "notifications_enabled"
    }

    static var `default`: UserPreferences {
        UserPreferences(
            monthlyIncome: 0,
            extraPayment: 0,
            payoffStrategy: "avalanche",
            notificationsEnabled: true
        )
    }
}

// MARK: - Plaid

struct PlaidLinkTokenResponse: Codable {
    let linkToken: String
    enum CodingKeys: String, CodingKey { case linkToken = "link_token" }
}

struct PlaidExchangeResponse: Codable {
    let success: Bool
    let accountsLinked: Int
    let transactionsSynced: Int
    enum CodingKeys: String, CodingKey {
        case success
        case accountsLinked      = "accounts_linked"
        case transactionsSynced  = "transactions_synced"
    }
}

// MARK: - API Error

struct APIError: Codable {
    let error: String
}

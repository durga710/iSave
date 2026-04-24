import Foundation
import Combine

@MainActor
final class CreditCardViewModel: ObservableObject {

    @Published var cards: [CreditCard] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api: APIService

    init(api: APIService) {
        self.api = api
    }

    // MARK: - Read

    func loadCards() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            cards = try await api.fetchCards()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Create

    func addCard(
        name: String,
        balance: Double,
        creditLimit: Double,
        apr: Double,
        minimumPayment: Double,
        cardType: String = "visa",
        color: String = "#007AFF"
    ) async {
        let stub = CreditCard(
            id: UUID().uuidString,    // backend will override with a real UUID
            name: name,
            balance: balance,
            creditLimit: creditLimit,
            apr: apr,
            minimumPayment: minimumPayment,
            cardType: cardType,
            color: color
        )
        do {
            let created = try await api.createCard(stub)
            cards.append(created)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Update

    func updateCard(_ card: CreditCard) async {
        do {
            let updated = try await api.updateCard(card)
            if let idx = cards.firstIndex(where: { $0.id == card.id }) {
                cards[idx] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete

    func deleteCard(id: String) async {
        do {
            try await api.deleteCard(id: id)
            cards.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteCards(at offsets: IndexSet) {
        let ids = offsets.map { cards[$0].id }
        Task {
            for id in ids { await deleteCard(id: id) }
        }
    }

    // MARK: - Computed helpers (used by PayoffEngine and UI)

    var totalBalance: Double       { cards.reduce(0) { $0 + $1.balance } }
    var totalCreditLimit: Double   { cards.reduce(0) { $0 + $1.creditLimit } }
    var totalMinimumPayment: Double { cards.reduce(0) { $0 + $1.minimumPayment } }
    var overallUtilization: Double {
        guard totalCreditLimit > 0 else { return 0 }
        return totalBalance / totalCreditLimit
    }
}

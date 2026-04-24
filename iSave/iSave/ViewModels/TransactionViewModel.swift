import Foundation
import Combine

@MainActor
final class TransactionViewModel: ObservableObject {

    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api: APIService

    init(api: APIService) {
        self.api = api
    }

    // MARK: - Read

    func loadAll(limit: Int = 100) async {
        await load(cardId: nil, limit: limit)
    }

    func loadForCard(_ cardId: String, limit: Int = 100) async {
        await load(cardId: cardId, limit: limit)
    }

    private func load(cardId: String?, limit: Int) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            transactions = try await api.fetchTransactions(cardId: cardId, limit: limit)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Create

    func addTransaction(
        creditCardId: String,
        amount: Double,
        description: String,
        category: String = "Other",
        date: Date = Date(),
        isPending: Bool = false
    ) async {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let stub = Transaction(
            id: UUID().uuidString,
            creditCardId: creditCardId,
            amount: amount,
            description: description,
            category: category,
            date: df.string(from: date),
            isPending: isPending
        )
        do {
            let created = try await api.createTransaction(stub)
            transactions.insert(created, at: 0)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Update

    func updateTransaction(_ tx: Transaction) async {
        do {
            let updated = try await api.updateTransaction(tx)
            if let idx = transactions.firstIndex(where: { $0.id == tx.id }) {
                transactions[idx] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete

    func deleteTransaction(id: String) async {
        do {
            try await api.deleteTransaction(id: id)
            transactions.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteTransactions(at offsets: IndexSet) {
        let ids = offsets.map { transactions[$0].id }
        Task {
            for id in ids { await deleteTransaction(id: id) }
        }
    }

    // MARK: - Computed helpers

    /// Monthly spending total
    var monthlyTotal: Double {
        let now = Calendar.current
        let startOfMonth = now.date(from: now.dateComponents([.year, .month], from: Date())) ?? Date()
        return transactions
            .filter { $0.parsedDate >= startOfMonth && !$0.isPending }
            .reduce(0) { $0 + $1.amount }
    }

    func total(forCategory category: String) -> Double {
        transactions
            .filter { $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }

    func transactions(for cardId: String) -> [Transaction] {
        transactions.filter { $0.creditCardId == cardId }
    }
}

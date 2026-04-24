import Foundation
import Combine

@MainActor
final class CategoryViewModel: ObservableObject {

    @Published var categories: [BudgetCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api: APIService

    init(api: APIService) {
        self.api = api
    }

    // MARK: - Read

    func loadCategories() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            categories = try await api.fetchCategories()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Create

    func addCategory(
        name: String,
        budgetAmount: Double,
        color: String = "#007AFF",
        icon: String = "tag"
    ) async {
        let stub = BudgetCategory(
            id: UUID().uuidString,
            name: name,
            budgetAmount: budgetAmount,
            color: color,
            icon: icon
        )
        do {
            let created = try await api.createCategory(stub)
            categories.append(created)
            categories.sort { $0.name < $1.name }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Update

    func updateCategory(_ cat: BudgetCategory) async {
        do {
            let updated = try await api.updateCategory(cat)
            if let idx = categories.firstIndex(where: { $0.id == cat.id }) {
                categories[idx] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete

    func deleteCategory(id: String) async {
        do {
            try await api.deleteCategory(id: id)
            categories.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteCategories(at offsets: IndexSet) {
        let ids = offsets.map { categories[$0].id }
        Task {
            for id in ids { await deleteCategory(id: id) }
        }
    }

    // MARK: - Computed helpers

    var totalBudget: Double { categories.reduce(0) { $0 + $1.budgetAmount } }

    func remainingBudget(spentByCategory: [String: Double]) -> Double {
        categories.reduce(0) { acc, cat in
            let spent = spentByCategory[cat.name] ?? 0
            return acc + max(cat.budgetAmount - spent, 0)
        }
    }
}

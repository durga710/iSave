import SwiftUI

struct BudgetView: View {
    @EnvironmentObject private var catVM: CategoryViewModel
    @EnvironmentObject private var txVM: TransactionViewModel
    @State private var showAdd = false
    @State private var editing: BudgetCategory?

    private var spentByCategory: [String: Double] {
        Dictionary(grouping: txVM.transactions, by: \.category)
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
    }

    var body: some View {
        NavigationStack {
            Group {
                if catVM.isLoading && catVM.categories.isEmpty {
                    ProgressView()
                } else if catVM.categories.isEmpty {
                    EmptyState(icon: "chart.pie", title: "No budget categories",
                               message: "Add a category to start tracking spending.")
                } else {
                    List {
                        Section {
                            HStack {
                                Text("Total Budget").bold()
                                Spacer()
                                Text(catVM.totalBudget, format: .currency(code: "USD")).bold()
                            }
                        }

                        ForEach(catVM.categories) { cat in
                            BudgetRow(category: cat, spent: spentByCategory[cat.name] ?? 0)
                                .contentShape(Rectangle())
                                .onTapGesture { editing = cat }
                        }
                        .onDelete { offsets in catVM.deleteCategories(at: offsets) }
                    }
                }
            }
            .navigationTitle("Budget")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) { AddEditCategoryView() }
            .sheet(item: $editing) { cat in AddEditCategoryView(category: cat) }
            .refreshable {
                async let a = catVM.loadCategories()
                async let b = txVM.loadAll()
                _ = await (a, b)
            }
        }
    }
}

struct BudgetRow: View {
    let category: BudgetCategory
    let spent: Double

    private var progress: Double {
        guard category.budgetAmount > 0 else { return 0 }
        return min(spent / category.budgetAmount, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundStyle(Color(hex: category.color) ?? .blue)
                Text(category.name).font(.headline)
                Spacer()
                Text("\(spent, format: .currency(code: "USD")) / \(category.budgetAmount, format: .currency(code: "USD"))")
                    .font(.caption)
            }
            ProgressView(value: progress)
                .tint(progress >= 1 ? .red : (Color(hex: category.color) ?? .blue))
        }
        .padding(.vertical, 4)
    }
}

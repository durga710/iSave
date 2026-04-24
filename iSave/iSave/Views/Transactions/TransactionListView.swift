import SwiftUI

struct TransactionListView: View {

    @EnvironmentObject private var txVM: TransactionViewModel
    @EnvironmentObject private var cardVM: CreditCardViewModel
    @State private var showAdd = false
    @State private var editing: Transaction?

    var body: some View {
        NavigationStack {
            Group {
                if txVM.isLoading && txVM.transactions.isEmpty {
                    ProgressView()
                } else if txVM.transactions.isEmpty {
                    EmptyState(icon: "list.bullet", title: "No transactions",
                               message: "Tap + to add a transaction or sync via Plaid.")
                } else {
                    List {
                        ForEach(txVM.transactions) { tx in
                            TransactionRow(tx: tx)
                                .contentShape(Rectangle())
                                .onTapGesture { editing = tx }
                        }
                        .onDelete { offsets in txVM.deleteTransactions(at: offsets) }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Activity")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                        .disabled(cardVM.cards.isEmpty)
                }
            }
            .sheet(isPresented: $showAdd) { AddEditTransactionView() }
            .sheet(item: $editing) { tx in AddEditTransactionView(transaction: tx) }
            .refreshable { await txVM.loadAll() }
        }
    }
}

struct TransactionRow: View {
    let tx: Transaction
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(tx.description).font(.subheadline)
                Text(tx.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(tx.amount, format: .currency(code: "USD"))
                    .font(.subheadline.bold())
                    .foregroundStyle(tx.isPending ? .secondary : .primary)
                Text(tx.parsedDate, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

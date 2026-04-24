import SwiftUI

struct CardListView: View {

    @EnvironmentObject private var cardVM: CreditCardViewModel
    @State private var showAddCard = false
    @State private var editingCard: CreditCard?

    var body: some View {
        NavigationStack {
            Group {
                if cardVM.isLoading && cardVM.cards.isEmpty {
                    ProgressView()
                } else if cardVM.cards.isEmpty {
                    EmptyState(
                        icon: "creditcard",
                        title: "No cards yet",
                        message: "Add your first credit card to get started."
                    )
                } else {
                    List {
                        ForEach(cardVM.cards) { card in
                            CardRow(card: card)
                                .contentShape(Rectangle())
                                .onTapGesture { editingCard = card }
                        }
                        .onDelete { offsets in cardVM.deleteCards(at: offsets) }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Credit Cards")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddCard = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddCard) {
                AddEditCardView()
            }
            .sheet(item: $editingCard) { card in
                AddEditCardView(card: card)
            }
            .refreshable { await cardVM.loadCards() }
        }
    }
}

struct CardRow: View {
    let card: CreditCard

    private var cardColor: Color {
        Color(hex: card.color) ?? .blue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundStyle(cardColor)
                Text(card.name).font(.headline)
                Spacer()
                Text(card.balance, format: .currency(code: "USD"))
                    .font(.headline)
            }
            HStack {
                Text("APR \(card.apr, specifier: "%.2f")%")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("Limit \(card.creditLimit, format: .currency(code: "USD"))")
                    .font(.caption).foregroundStyle(.secondary)
            }
            ProgressView(value: card.utilization)
                .tint(card.utilization > 0.3 ? .red : .green)
        }
        .padding(.vertical, 4)
    }
}

struct EmptyState: View {
    let icon: String
    let title: String
    let message: String
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 56)).foregroundStyle(.secondary)
            Text(title).font(.title3.bold())
            Text(message).font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

extension Color {
    init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = UInt64(s, radix: 16) else { return nil }
        self.init(
            red:   Double((v >> 16) & 0xFF) / 255.0,
            green: Double((v >> 8)  & 0xFF) / 255.0,
            blue:  Double(v         & 0xFF) / 255.0
        )
    }
}

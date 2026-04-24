import SwiftUI

struct AddEditCardView: View {
    @EnvironmentObject private var cardVM: CreditCardViewModel
    @Environment(\.dismiss) private var dismiss

    private let editing: CreditCard?

    @State private var name = ""
    @State private var balanceText = ""
    @State private var limitText = ""
    @State private var aprText = ""
    @State private var minPaymentText = ""
    @State private var cardType = "visa"
    @State private var color = "#007AFF"

    @State private var validationError: String?

    init(card: CreditCard? = nil) {
        self.editing = card
        _name           = State(initialValue: card?.name ?? "")
        _balanceText    = State(initialValue: card.map { String(format: "%.2f", $0.balance) } ?? "")
        _limitText      = State(initialValue: card.map { String(format: "%.2f", $0.creditLimit) } ?? "")
        _aprText        = State(initialValue: card.map { String(format: "%.2f", $0.apr) } ?? "")
        _minPaymentText = State(initialValue: card.map { String(format: "%.2f", $0.minimumPayment) } ?? "")
        _cardType       = State(initialValue: card?.cardType ?? "visa")
        _color          = State(initialValue: card?.color ?? "#007AFF")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Card Details") {
                    TextField("Card name (e.g. Chase Sapphire)", text: $name)
                    Picker("Type", selection: $cardType) {
                        Text("Visa").tag("visa")
                        Text("Mastercard").tag("mastercard")
                        Text("Amex").tag("amex")
                        Text("Discover").tag("discover")
                        Text("Other").tag("other")
                    }
                }

                Section("Balances") {
                    NumberField(label: "Current Balance", text: $balanceText)
                    NumberField(label: "Credit Limit", text: $limitText)
                    NumberField(label: "APR (%)", text: $aprText)
                    NumberField(label: "Min Payment", text: $minPaymentText)
                }

                Section("Color") {
                    Picker("Color", selection: $color) {
                        ForEach(["#007AFF", "#34C759", "#FF9500", "#FF3B30", "#AF52DE", "#5856D6"], id: \.self) { hex in
                            HStack {
                                Circle().fill(Color(hex: hex) ?? .blue).frame(width: 20, height: 20)
                                Text(hex)
                            }.tag(hex)
                        }
                    }
                }

                if let validationError {
                    Text(validationError).foregroundStyle(.red).font(.footnote)
                }
            }
            .navigationTitle(editing == nil ? "Add Card" : "Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { Task { await save() } }.bold()
                }
            }
        }
    }

    private func save() async {
        guard validate() else { return }
        let balance  = Double(balanceText) ?? 0
        let limit    = Double(limitText) ?? 0
        let apr      = Double(aprText) ?? 0
        let minPay   = Double(minPaymentText) ?? 0

        if let editing {
            var updated = editing
            updated.name = name
            updated.balance = balance
            updated.creditLimit = limit
            updated.apr = apr
            updated.minimumPayment = minPay
            updated.cardType = cardType
            updated.color = color
            await cardVM.updateCard(updated)
        } else {
            await cardVM.addCard(
                name: name, balance: balance, creditLimit: limit,
                apr: apr, minimumPayment: minPay, cardType: cardType, color: color
            )
        }
        dismiss()
    }

    private func validate() -> Bool {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            validationError = "Name is required"; return false
        }
        if Double(balanceText) == nil || (Double(balanceText) ?? -1) < 0 {
            validationError = "Balance must be a non-negative number"; return false
        }
        if Double(limitText) == nil || (Double(limitText) ?? -1) < 0 {
            validationError = "Limit must be a non-negative number"; return false
        }
        if Double(aprText) == nil || (Double(aprText) ?? -1) < 0 {
            validationError = "APR must be non-negative"; return false
        }
        validationError = nil
        return true
    }
}

struct NumberField: View {
    let label: String
    @Binding var text: String
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            TextField("0.00", text: $text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 120)
        }
    }
}

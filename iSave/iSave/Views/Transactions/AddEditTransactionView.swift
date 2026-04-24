import SwiftUI

struct AddEditTransactionView: View {

    @EnvironmentObject private var txVM: TransactionViewModel
    @EnvironmentObject private var cardVM: CreditCardViewModel
    @Environment(\.dismiss) private var dismiss

    private let editing: Transaction?

    @State private var amountText = ""
    @State private var description = ""
    @State private var category = "Food"
    @State private var date = Date()
    @State private var creditCardId = ""
    @State private var isPending = false

    @State private var validationError: String?

    private let categories = ["Food", "Transport", "Shopping", "Bills", "Entertainment", "Health", "Travel", "Other"]

    init(transaction: Transaction? = nil) {
        self.editing = transaction
        _amountText   = State(initialValue: transaction.map { String(format: "%.2f", $0.amount) } ?? "")
        _description  = State(initialValue: transaction?.description ?? "")
        _category     = State(initialValue: transaction?.category ?? "Food")
        _creditCardId = State(initialValue: transaction?.creditCardId ?? "")
        _isPending    = State(initialValue: transaction?.isPending ?? false)
        if let dateStr = transaction?.date {
            let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
            _date = State(initialValue: df.date(from: dateStr) ?? Date())
        } else {
            _date = State(initialValue: Date())
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Description", text: $description)
                    NumberField(label: "Amount", text: $amountText)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0).tag($0) }
                    }
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Toggle("Pending", isOn: $isPending)
                }

                Section("Card") {
                    Picker("Card", selection: $creditCardId) {
                        Text("Select…").tag("")
                        ForEach(cardVM.cards) { c in
                            Text(c.name).tag(c.id)
                        }
                    }
                }

                if let validationError {
                    Text(validationError).foregroundStyle(.red).font(.footnote)
                }
            }
            .navigationTitle(editing == nil ? "Add Transaction" : "Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { Task { await save() } }.bold()
                }
            }
            .onAppear {
                if creditCardId.isEmpty, let first = cardVM.cards.first {
                    creditCardId = first.id
                }
            }
        }
    }

    private func save() async {
        guard validate() else { return }
        let amount = Double(amountText) ?? 0
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
        let dateStr = df.string(from: date)

        if let editing {
            var updated = editing
            updated.amount = amount
            updated.description = description
            updated.category = category
            updated.date = dateStr
            updated.isPending = isPending
            await txVM.updateTransaction(updated)
        } else {
            await txVM.addTransaction(
                creditCardId: creditCardId,
                amount: amount,
                description: description,
                category: category,
                date: date,
                isPending: isPending
            )
        }
        dismiss()
    }

    private func validate() -> Bool {
        if description.trimmingCharacters(in: .whitespaces).isEmpty {
            validationError = "Description required"; return false
        }
        if Double(amountText) == nil || (Double(amountText) ?? 0) <= 0 {
            validationError = "Amount must be greater than zero"; return false
        }
        if creditCardId.isEmpty {
            validationError = "Pick a card"; return false
        }
        validationError = nil
        return true
    }
}

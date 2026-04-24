import SwiftUI

struct AddEditCategoryView: View {
    @EnvironmentObject private var catVM: CategoryViewModel
    @Environment(\.dismiss) private var dismiss

    private let editing: BudgetCategory?

    @State private var name = ""
    @State private var amountText = ""
    @State private var color = "#007AFF"
    @State private var icon = "tag"
    @State private var validationError: String?

    private let icons = ["tag", "fork.knife", "car", "cart", "house", "heart",
                         "airplane", "tv", "gamecontroller", "book"]

    init(category: BudgetCategory? = nil) {
        self.editing = category
        _name       = State(initialValue: category?.name ?? "")
        _amountText = State(initialValue: category.map { String(format: "%.2f", $0.budgetAmount) } ?? "")
        _color      = State(initialValue: category?.color ?? "#007AFF")
        _icon       = State(initialValue: category?.icon ?? "tag")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    TextField("Name", text: $name)
                    NumberField(label: "Monthly Budget", text: $amountText)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(icons, id: \.self) { sym in
                            Image(systemName: sym)
                                .font(.title3)
                                .frame(width: 44, height: 44)
                                .background(icon == sym ? Color.blue.opacity(0.2) : Color.clear)
                                .foregroundStyle(icon == sym ? .blue : .primary)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .onTapGesture { icon = sym }
                        }
                    }
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
            .navigationTitle(editing == nil ? "Add Category" : "Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { Task { await save() } }.bold()
                }
            }
        }
    }

    private func save() async {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            validationError = "Name required"; return
        }
        let amount = Double(amountText) ?? 0
        if amount < 0 {
            validationError = "Budget must be non-negative"; return
        }
        if let editing {
            var u = editing
            u.name = name; u.budgetAmount = amount; u.color = color; u.icon = icon
            await catVM.updateCategory(u)
        } else {
            await catVM.addCategory(name: name, budgetAmount: amount, color: color, icon: icon)
        }
        dismiss()
    }
}

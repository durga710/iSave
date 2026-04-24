import SwiftUI

struct SettingsView: View {

    @EnvironmentObject private var authVM: AuthViewModel
    @EnvironmentObject private var prefsVM: UserPreferencesViewModel
    @EnvironmentObject private var plaidManager: PlaidManager

    @State private var incomeText       = ""
    @State private var extraPaymentText = ""
    @State private var showSyncSuccess  = false

    var body: some View {
        NavigationStack {
            Form {

                // ── Bank Accounts ───────────────────────────────────────────
                Section {
                    // Link a new bank account via Plaid
                    Button {
                        plaidManager.startLink()
                    } label: {
                        HStack {
                            Label("Link Bank Account", systemImage: "building.columns")
                                .foregroundStyle(.primary)
                            Spacer()
                            if plaidManager.isLoading {
                                ProgressView()
                            } else {
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                                    .font(.footnote)
                            }
                        }
                    }
                    .disabled(plaidManager.isLoading)

                    // Sync existing linked accounts
                    Button {
                        plaidManager.syncNow()
                    } label: {
                        Label("Sync Transactions", systemImage: "arrow.clockwise")
                    }
                    .disabled(plaidManager.isLoading)

                    if let result = plaidManager.lastSyncResult {
                        Text("\(result.transactionsSynced) transactions synced")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let err = plaidManager.errorMessage {
                        Text(err)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Bank Accounts")
                } footer: {
                    Text("iSave connects through Plaid. Only credit accounts are imported.")
                }

                // ── Income & Payments ───────────────────────────────────────
                Section("Income & Payments") {
                    HStack {
                        Text("Monthly Income")
                        Spacer()
                        TextField("$0", text: $incomeText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .onAppear {
                                incomeText = currencyString(prefsVM.preferences.monthlyIncome)
                            }
                            .onSubmit { saveIncome() }
                    }

                    HStack {
                        Text("Extra Payment")
                        Spacer()
                        TextField("$0", text: $extraPaymentText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                            .onAppear {
                                extraPaymentText = currencyString(prefsVM.preferences.extraPayment)
                            }
                            .onSubmit { saveExtraPayment() }
                    }
                }

                // ── Payoff Strategy ─────────────────────────────────────────
                Section("Payoff Strategy") {
                    Picker("Strategy", selection: Binding(
                        get: { prefsVM.preferences.payoffStrategy },
                        set: { strategy in Task { await prefsVM.setPayoffStrategy(strategy) } }
                    )) {
                        Text("Avalanche (highest APR first)").tag("avalanche")
                        Text("Snowball (lowest balance first)").tag("snowball")
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                // ── Notifications ───────────────────────────────────────────
                Section("Notifications") {
                    Toggle("Payment Reminders", isOn: Binding(
                        get: { prefsVM.preferences.notificationsEnabled },
                        set: { enabled in Task { await prefsVM.setNotificationsEnabled(enabled) } }
                    ))
                }

                // ── Account ─────────────────────────────────────────────────
                Section("Account") {
                    if let user = authVM.currentUser {
                        LabeledContent("Email", value: user.email)
                        if let name = user.name {
                            LabeledContent("Name", value: name)
                        }
                    }

                    Button(role: .destructive) {
                        authVM.logout()
                    } label: {
                        Text("Sign Out")
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $plaidManager.isShowingLink) {
                plaidManager.linkView()
                    .ignoresSafeArea()
            }
        }
    }

    // MARK: - Helpers

    private func saveIncome() {
        let value = Double(incomeText.replacingOccurrences(of: "$", with: "")
                              .replacingOccurrences(of: ",", with: "")) ?? 0
        Task { await prefsVM.setMonthlyIncome(value) }
    }

    private func saveExtraPayment() {
        let value = Double(extraPaymentText.replacingOccurrences(of: "$", with: "")
                               .replacingOccurrences(of: ",", with: "")) ?? 0
        Task { await prefsVM.setExtraPayment(value) }
    }

    private func currencyString(_ value: Double) -> String {
        value == 0 ? "" : String(format: "%.2f", value)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel(api: APIService()))
        .environmentObject(UserPreferencesViewModel(api: APIService()))
        .environmentObject(PlaidManager(api: APIService()))
}

import SwiftUI

struct DashboardView: View {

    @EnvironmentObject private var cardVM: CreditCardViewModel
    @EnvironmentObject private var txVM: TransactionViewModel
    @EnvironmentObject private var prefsVM: UserPreferencesViewModel
    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    header
                    summaryCards
                    recentTransactions
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .refreshable {
                async let a = cardVM.loadCards()
                async let b = txVM.loadAll()
                async let c = prefsVM.loadPreferences()
                _ = await (a, b, c)
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back")
                    .font(.subheadline).foregroundStyle(.secondary)
                Text(authVM.currentUser?.name ?? authVM.currentUser?.email ?? "User")
                    .font(.title2.bold())
            }
            Spacer()
        }
    }

    private var summaryCards: some View {
        VStack(spacing: 12) {
            SummaryCard(title: "Total Balance",
                        value: cardVM.totalBalance,
                        icon: "creditcard",
                        tint: .red)
            SummaryCard(title: "Total Credit Limit",
                        value: cardVM.totalCreditLimit,
                        icon: "dollarsign.circle",
                        tint: .green)
            SummaryCard(title: "Min Payments Due",
                        value: cardVM.totalMinimumPayment,
                        icon: "calendar",
                        tint: .orange)
            SummaryCard(title: "Spent This Month",
                        value: txVM.monthlyTotal,
                        icon: "cart",
                        tint: .blue)

            HStack {
                Text("Utilization")
                    .font(.subheadline)
                Spacer()
                Text(String(format: "%.0f%%", cardVM.overallUtilization * 100))
                    .font(.subheadline.bold())
                    .foregroundStyle(cardVM.overallUtilization > 0.3 ? .red : .green)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var recentTransactions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Transactions")
                .font(.headline)

            if txVM.transactions.isEmpty {
                Text("No transactions yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(txVM.transactions.prefix(5)) { tx in
                    TransactionRow(tx: tx)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SummaryCard: View {
    let title: String
    let value: Double
    let icon: String
    let tint: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(tint.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption).foregroundStyle(.secondary)
                Text(value, format: .currency(code: "USD"))
                    .font(.title3.bold())
            }
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

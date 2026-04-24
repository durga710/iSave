import SwiftUI

struct PayoffView: View {
    @EnvironmentObject private var cardVM: CreditCardViewModel
    @EnvironmentObject private var prefsVM: UserPreferencesViewModel

    private var plan: PayoffPlan {
        let strategy = PayoffStrategy(rawValue: prefsVM.preferences.payoffStrategy) ?? .avalanche
        return PayoffEngine.computePlan(
            cards: cardVM.cards,
            strategy: strategy,
            extraMonthlyPayment: prefsVM.preferences.extraPayment
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {

                    if cardVM.cards.isEmpty {
                        EmptyState(icon: "flag.checkered",
                                   title: "No plan yet",
                                   message: "Add cards and set a strategy in Settings.")
                            .padding(.top, 80)
                    } else {
                        summary
                        strategyBadge
                        payoffOrderList
                    }
                }
                .padding()
            }
            .navigationTitle("Payoff Plan")
        }
    }

    private var summary: some View {
        VStack(spacing: 12) {
            MetricCard(
                title: "Months to Debt-Free",
                value: plan.monthsToDebtFree == 0 ? "—" : "\(plan.monthsToDebtFree)",
                subtitle: plan.monthsToDebtFree > 0
                    ? "≈ \(String(format: "%.1f", Double(plan.monthsToDebtFree)/12.0)) years"
                    : "Increase payments to project",
                tint: .blue
            )
            MetricCard(
                title: "Total Interest",
                value: format(plan.totalInterestPaid),
                subtitle: "Paid over full plan",
                tint: .red
            )
            MetricCard(
                title: "Total Paid",
                value: format(plan.totalPaid),
                subtitle: "Principal + interest",
                tint: .green
            )
        }
    }

    private var strategyBadge: some View {
        HStack {
            Image(systemName: prefsVM.preferences.payoffStrategy == "avalanche"
                  ? "chart.line.downtrend.xyaxis"
                  : "snowflake")
            Text("Strategy: \(prefsVM.preferences.payoffStrategy.capitalized)")
                .font(.subheadline.bold())
            Spacer()
            Text("+ \(prefsVM.preferences.extraPayment, format: .currency(code: "USD"))/mo")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var payoffOrderList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Payoff Order").font(.headline)
            ForEach(Array(plan.payoffOrder.enumerated()), id: \.element.id) { idx, step in
                HStack {
                    Text("\(idx + 1).")
                        .font(.headline).foregroundStyle(.secondary)
                        .frame(width: 28, alignment: .leading)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(step.cardName).font(.subheadline.bold())
                        Text("Paid off in \(step.payoffMonth) mo • Interest \(format(step.interestPaid))")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private func format(_ v: Double) -> String {
        v.formatted(.currency(code: "USD"))
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let tint: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title.bold()).foregroundStyle(tint)
            Text(subtitle).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

import Foundation

// MARK: - PayoffEngine
//
// Pure-functional debt payoff calculator. Supports avalanche (highest APR
// first) and snowball (lowest balance first) strategies plus an optional
// monthly extra payment that is applied to the highest-priority card.

struct PayoffPlan {
    let monthsToDebtFree: Int
    let totalInterestPaid: Double
    let totalPaid: Double
    let payoffOrder: [PayoffStep]
}

struct PayoffStep: Identifiable {
    let id = UUID()
    let cardId: String
    let cardName: String
    let payoffMonth: Int        // # of months from now until this card hits zero
    let interestPaid: Double
}

enum PayoffStrategy: String {
    case avalanche, snowball
}

enum PayoffEngine {

    // ─── Public API ──────────────────────────────────────────────────────

    static func computePlan(
        cards: [CreditCard],
        strategy: PayoffStrategy,
        extraMonthlyPayment: Double = 0,
        maxMonths: Int = 600          // 50-year safety cap
    ) -> PayoffPlan {

        // Snapshot mutable state we can mutate during simulation
        var balances: [String: Double] = [:]
        var interestPaid: [String: Double] = [:]
        var totalPaid:    [String: Double] = [:]
        var payoffMonth:  [String: Int]    = [:]

        for c in cards {
            balances[c.id]      = c.balance
            interestPaid[c.id]  = 0
            totalPaid[c.id]     = 0
        }

        var month = 0
        let aprs:    [String: Double] = Dictionary(uniqueKeysWithValues: cards.map { ($0.id, $0.apr) })
        let mins:    [String: Double] = Dictionary(uniqueKeysWithValues: cards.map { ($0.id, $0.minimumPayment) })
        let names:   [String: String] = Dictionary(uniqueKeysWithValues: cards.map { ($0.id, $0.name) })

        while month < maxMonths {
            // Stop if every balance is paid
            if balances.values.allSatisfy({ $0 <= 0.005 }) { break }
            month += 1

            // Apply this month's interest to every still-open balance
            for id in balances.keys where (balances[id] ?? 0) > 0 {
                let monthlyRate = (aprs[id] ?? 0) / 100.0 / 12.0
                let interest = (balances[id] ?? 0) * monthlyRate
                balances[id, default: 0]     += interest
                interestPaid[id, default: 0] += interest
            }

            // Pay minimums on all open cards
            var leftoverExtra = extraMonthlyPayment
            for id in balances.keys where (balances[id] ?? 0) > 0 {
                let pay = min(mins[id] ?? 0, balances[id] ?? 0)
                balances[id, default: 0] -= pay
                totalPaid[id, default: 0] += pay
            }

            // Direct extra payment to the highest-priority open card
            let openIds = balances.keys.filter { (balances[$0] ?? 0) > 0 }
            let priorityOrder = sortIds(openIds, strategy: strategy, cards: cards)

            for id in priorityOrder {
                guard leftoverExtra > 0, (balances[id] ?? 0) > 0 else { continue }
                let pay = min(leftoverExtra, balances[id] ?? 0)
                balances[id, default: 0] -= pay
                totalPaid[id, default: 0] += pay
                leftoverExtra -= pay
            }

            // Mark any cards that just hit zero
            for id in balances.keys where (balances[id] ?? 0) <= 0.005 && payoffMonth[id] == nil {
                payoffMonth[id] = month
            }
        }

        let order = cards
            .compactMap { card -> PayoffStep? in
                guard let m = payoffMonth[card.id] else { return nil }
                return PayoffStep(
                    cardId: card.id,
                    cardName: names[card.id] ?? card.name,
                    payoffMonth: m,
                    interestPaid: interestPaid[card.id] ?? 0
                )
            }
            .sorted { $0.payoffMonth < $1.payoffMonth }

        let totalInterest = interestPaid.values.reduce(0, +)
        let totalAllPaid  = totalPaid.values.reduce(0, +)
        let monthsToFree  = order.last?.payoffMonth ?? 0

        return PayoffPlan(
            monthsToDebtFree: monthsToFree,
            totalInterestPaid: totalInterest,
            totalPaid: totalAllPaid,
            payoffOrder: order
        )
    }

    // ─── Private ──────────────────────────────────────────────────────────

    private static func sortIds(
        _ ids: [String],
        strategy: PayoffStrategy,
        cards: [CreditCard]
    ) -> [String] {
        let cardById = Dictionary(uniqueKeysWithValues: cards.map { ($0.id, $0) })
        switch strategy {
        case .avalanche:
            return ids.sorted { (cardById[$0]?.apr ?? 0) > (cardById[$1]?.apr ?? 0) }
        case .snowball:
            return ids.sorted { (cardById[$0]?.balance ?? 0) < (cardById[$1]?.balance ?? 0) }
        }
    }
}

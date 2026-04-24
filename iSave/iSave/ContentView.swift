import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            CardListView()
                .tabItem { Label("Cards", systemImage: "creditcard.fill") }

            TransactionListView()
                .tabItem { Label("Activity", systemImage: "list.bullet.rectangle") }

            BudgetView()
                .tabItem { Label("Budget", systemImage: "chart.pie.fill") }

            PayoffView()
                .tabItem { Label("Payoff", systemImage: "flag.checkered") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel(api: APIService()))
        .environmentObject(CreditCardViewModel(api: APIService()))
        .environmentObject(TransactionViewModel(api: APIService()))
        .environmentObject(CategoryViewModel(api: APIService()))
        .environmentObject(UserPreferencesViewModel(api: APIService()))
        .environmentObject(PlaidManager(api: APIService()))
}

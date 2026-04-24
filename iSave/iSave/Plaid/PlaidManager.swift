import SwiftUI

// MARK: - PlaidManager
//
// This stub compiles without the Plaid LinkKit SDK so the project runs in
// the simulator out-of-the-box. The backend endpoints (/plaid/*) are fully
// functional — to enable the real Plaid Link flow:
//
//   1. In Xcode: File → Add Package Dependencies…
//      https://github.com/plaid/plaid-link-ios
//      Add the `LinkKit` product to the iSave target.
//
//   2. Uncomment the `import LinkKit` line below and the real implementation
//      block at the bottom of this file (delete the stub `startLink` body).
//
// import LinkKit

@MainActor
final class PlaidManager: ObservableObject {

    @Published var isLoading      = false
    @Published var errorMessage: String?
    @Published var lastSyncResult: PlaidExchangeResponse?
    @Published var isShowingLink  = false
    @Published var statusMessage: String?

    private let api: APIService

    init(api: APIService) {
        self.api = api
    }

    // ── Stub: fetches a real link token from the backend, then informs the
    //         user the SDK still needs to be installed before the Link UI
    //         can be presented.
    func startLink() {
        Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }
            do {
                _ = try await api.createPlaidLinkToken()
                statusMessage = "Plaid link token created. Install LinkKit SDK to present the Link UI."
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func syncNow() {
        Task {
            isLoading = true
            errorMessage = nil
            defer { isLoading = false }
            do {
                lastSyncResult = try await api.syncPlaid()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func linkView() -> some View {
        Text("Install Plaid LinkKit SDK to enable bank linking.")
            .padding()
    }
}

/*
// ─── Real LinkKit implementation (uncomment after adding the SDK) ────────────

@MainActor
final class PlaidManagerReal: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastSyncResult: PlaidExchangeResponse?
    @Published var isShowingLink = false

    private var handler: Handler?
    private let api: APIService

    init(api: APIService) { self.api = api }

    func startLink() {
        Task {
            isLoading = true; defer { isLoading = false }
            do {
                let token = try await api.createPlaidLinkToken()
                var config = LinkTokenConfiguration(token: token) { [weak self] success in
                    guard let self else { return }
                    self.isShowingLink = false
                    Task { @MainActor in
                        self.lastSyncResult = try? await self.api.exchangePlaidToken(
                            publicToken: success.publicToken,
                            institutionName: success.metadata.institution?.name ?? "Bank"
                        )
                    }
                }
                config.onExit = { [weak self] exit in
                    self?.isShowingLink = false
                    if let err = exit.error { self?.errorMessage = err.localizedDescription }
                }
                switch Plaid.create(config) {
                case .success(let h): self.handler = h; self.isShowingLink = true
                case .failure(let e): self.errorMessage = e.localizedDescription
                }
            } catch { errorMessage = error.localizedDescription }
        }
    }

    func syncNow() {
        Task {
            do { lastSyncResult = try await api.syncPlaid() }
            catch { errorMessage = error.localizedDescription }
        }
    }

    func linkView() -> some View { PlaidLinkRepresentable(handler: handler) }
}

private struct PlaidLinkRepresentable: UIViewControllerRepresentable {
    let handler: Handler?
    func makeUIViewController(context: Context) -> UIViewController { UIViewController() }
    func updateUIViewController(_ vc: UIViewController, context: Context) {
        guard let handler, vc.presentedViewController == nil else { return }
        handler.open(presentUsing: .custom { linkVC in vc.present(linkVC, animated: true) })
    }
}
*/

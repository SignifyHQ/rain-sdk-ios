import Foundation
import RainSDK

@MainActor
class GetTransactionsDemoViewModel: ObservableObject {
  @Published var limit: String = "20"
  @Published var orderOption: WalletTransactionOrder = .DESC
  @Published var transactions: [WalletTransaction] = []
  @Published var isLoading: Bool = false
  @Published var statusMessage: String = "Ready"
  @Published var error: Error?
  @Published var hasFetched: Bool = false

  private let sdkService = RainSDKService.shared

  /// Network selected on the connection screen.
  var chain: WalletChain { sdkService.selectedChain }

  var canFetch: Bool {
    sdkService.isInitialized
  }

  func fetchTransactions() async {
    guard canFetch else { return }
    let limitInt = Int(limit).flatMap { $0 > 0 ? $0 : nil }

    isLoading = true
    statusMessage = "Fetching transactions..."
    error = nil
    transactions = []

    do {
      let result = try await sdkService.getTransactions(
        chainId: chain.chainId,
        limit: limitInt,
        offset: nil,
        order: orderOption
      )
      transactions = result
      statusMessage = "Loaded \(result.count) transaction(s)"
      error = nil
    } catch {
      self.error = error
      statusMessage = "Failed to get transactions"
    }
    isLoading = false
    hasFetched = true
  }
}

import Foundation
import RainSDK

@MainActor
class GetTransactionsDemoViewModel: ObservableObject {
  @Published var chainId: String = "43113"
  @Published var limit: String = "20"
  @Published var orderOption: WalletTransactionOrder = .DESC
  @Published var transactions: [WalletTransaction] = []
  @Published var isLoading: Bool = false
  @Published var statusMessage: String = "Ready"
  @Published var error: Error?

  private let sdkService = RainSDKService.shared

  var canFetch: Bool {
    sdkService.isInitialized
      && !chainId.isEmpty
      && Int(chainId) != nil
  }

  func fetchTransactions() async {
    guard let chainIdInt = Int(chainId), canFetch else { return }
    let limitInt = Int(limit).flatMap { $0 > 0 ? $0 : nil }

    isLoading = true
    statusMessage = "Fetching transactions..."
    error = nil
    transactions = []

    do {
      let result = try await sdkService.getTransactions(
        chainId: chainIdInt,
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
  }
}

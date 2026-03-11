import Foundation

@MainActor
class GetBalancesDemoViewModel: ObservableObject {
  @Published var chainId: String = "43113"
  @Published var balances: [String: Double] = [:]
  @Published var isLoading: Bool = false
  @Published var statusMessage: String = "Ready"
  @Published var error: Error?

  private let sdkService = RainSDKService.shared

  var canFetch: Bool {
    sdkService.isInitialized
      && !chainId.isEmpty
      && Int(chainId) != nil
  }

  /// Display label for balance key: "" -> "Native", otherwise shortened address.
  static func label(for key: String) -> String {
    if key.isEmpty { return "Native" }
    if key.count <= 12 { return key }
    return "\(key.prefix(6))...\(key.suffix(6))"
  }

  /// Sorted entries for display: native first, then by address.
  var sortedEntries: [(key: String, value: Double)] {
    balances.sorted { lhs, rhs in
      if lhs.key.isEmpty { return true }
      if rhs.key.isEmpty { return false }
      return lhs.key < rhs.key
    }
  }

  func fetchBalances() async {
    guard let chainIdInt = Int(chainId), canFetch else { return }
    isLoading = true
    statusMessage = "Fetching balances..."
    error = nil
    balances = [:]

    do {
      let result = try await sdkService.getBalances(chainId: chainIdInt)
      balances = result
      statusMessage = "Loaded \(result.count) balance(s)"
      error = nil
    } catch {
      self.error = error
      statusMessage = "Failed to get balances"
    }
    isLoading = false
  }
}

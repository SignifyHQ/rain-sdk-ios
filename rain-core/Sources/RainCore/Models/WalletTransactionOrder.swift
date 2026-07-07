import Foundation

/// Sort order for transaction history (e.g. in `getTransactions(chainId:limit:offset:order:)`).
/// Provider-agnostic; adapters map it to their own transaction ordering type inside their module.
public enum WalletTransactionOrder: String, Codable, Sendable {
  case ASC
  case DESC
}

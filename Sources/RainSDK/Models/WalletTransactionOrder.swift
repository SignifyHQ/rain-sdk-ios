import Foundation
import PortalSwift

/// Sort order for transaction history (e.g. in `getTransactions(chainId:limit:offset:order:)`).
/// Provider-agnostic; mapped to Portal's `TransactionOrder` (or equivalent) inside adapters.
public enum WalletTransactionOrder: String, Codable, Sendable {
  case ASC
  case DESC
}

extension WalletTransactionOrder {
  /// Maps to Portal's `TransactionOrder` for use in Portal provider adapter.
  internal var toPortalOrder: TransactionOrder {
    switch self {
    case .ASC: return .ASC
    case .DESC: return .DESC
    }
  }
}

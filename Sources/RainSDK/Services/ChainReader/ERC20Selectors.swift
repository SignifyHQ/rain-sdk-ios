import Foundation

/// 4-byte method selectors for ERC-20 functions (`keccak256(signature)[:4]`).
/// Centralized so the hex literals don't sprawl across adapters.
internal enum ERC20Selectors {
  /// `balanceOf(address)`
  static let balanceOf = "70a08231"

  /// `symbol()`
  static let symbol = "95d89b41"

  /// `decimals()`
  static let decimals = "313ce567"
}

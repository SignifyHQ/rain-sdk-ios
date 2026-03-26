import Foundation
import PortalSwift

/// Utility functions for Ethereum data conversion.
/// Mirrors Android's `EthereumConverter` utility class.
enum EthereumConverter {

  // MARK: - Portal Result Extraction

  /// Extracts a hex string from a `PortalProviderResult`, mirroring Android's `convertPortalResultToHexString`.
  ///
  /// Handles two shapes Portal can return:
  ///   - `result` is a raw `String` (e.g. some RPC methods return the hex directly)
  ///   - `result` is a `PortalProviderRpcResponse` whose nested `.result` holds the hex string
  ///
  /// - Returns: The hex string (e.g. `"0x1a2b…"`) or `"0x0"` when missing/invalid.
  static func extractHexString(from portalResult: PortalProviderResult) -> String {
    let hex: String?
    switch portalResult.result {
    case let str as String:
      hex = str
    case let rpcResponse as PortalProviderRpcResponse:
      hex = rpcResponse.result
    default:
      hex = nil
    }

    guard let hex, hex.hasPrefix("0x"), hex.count > 2 else {
      return "0x0"
    }

    return hex
  }

  // MARK: - Hex to Numeric Conversion

  /// Converts a hex-encoded uint256 string (e.g. from `eth_call`) to a human-readable `Double` using token decimals.
  ///
  /// Uses `NSDecimalNumber` for safe handling of the full uint256 range.
  ///
  /// - Parameters:
  ///   - hex: Hex string with or without `0x` prefix (e.g. `"0x0de0b6b3a7640000"`).
  ///   - decimals: Number of decimal places the token uses (e.g. 6 for USDC, 18 for ETH).
  /// - Returns: Human-readable balance as `Double` (e.g. `1.0` for 1 ETH).
  static func parseHexToDouble(_ hex: String, decimals: Int) -> Double {
    let cleanHex = hex.hasPrefix("0x") ? String(hex.dropFirst(2)) : hex
    guard !cleanHex.isEmpty else { return 0 }

    var value = NSDecimalNumber.zero
    let sixteen = NSDecimalNumber(value: 16)
    for char in cleanHex {
      guard let digit = Int(String(char), radix: 16) else { continue }
      value = value.multiplying(by: sixteen).adding(NSDecimalNumber(value: digit))
    }

    let divisor = NSDecimalNumber(mantissa: 1, exponent: Int16(decimals), isNegative: false)
    return value.dividing(by: divisor).doubleValue
  }
}

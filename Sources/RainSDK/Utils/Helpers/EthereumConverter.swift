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
  /// Converts a hex-encoded uint256 string to an `Int` (e.g. for ERC-20 `decimals()` responses).
  static func parseHexToInt(_ hex: String) -> Int {
    let cleanHex = hex.hasPrefix("0x") ? String(hex.dropFirst(2)) : hex
    guard !cleanHex.isEmpty else { return 0 }
    return Int(cleanHex, radix: 16) ?? 0
  }

  /// Decodes an ABI-encoded string returned by `eth_call` (e.g. from ERC-20 `symbol()`).
  ///
  /// ABI string layout (each slot = 32 bytes = 64 hex chars):
  ///   slot 0 — offset to data (usually 0x20)
  ///   slot 1 — byte length of string
  ///   slot 2+ — UTF-8 string bytes, right-padded to 32-byte boundary
  static func parseHexToString(_ hex: String) -> String? {
    let cleanHex = hex.hasPrefix("0x") ? String(hex.dropFirst(2)) : hex
    guard cleanHex.count >= 128 else { return nil }

    let lengthHex = String(cleanHex.dropFirst(64).prefix(64))
    guard let byteLength = Int(lengthHex, radix: 16), byteLength > 0 else { return nil }

    let dataHex = String(cleanHex.dropFirst(128).prefix(byteLength * 2))
    guard dataHex.count == byteLength * 2 else { return nil }

    var bytes = [UInt8]()
    bytes.reserveCapacity(byteLength)
    var index = dataHex.startIndex
    while index < dataHex.endIndex {
      let next = dataHex.index(index, offsetBy: 2)
      if let byte = UInt8(dataHex[index..<next], radix: 16) { bytes.append(byte) }
      index = next
    }
    return String(bytes: bytes, encoding: .utf8)
  }

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

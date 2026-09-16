import Foundation
import Web3

extension EthereumAddress {
  /// Parses a user- or host-supplied address string, validating length, prefix and hex content.
  ///
  /// NEVER use the library's `init?(hexString:)` to parse input: that is an ABI-DECODING
  /// initializer expecting a 32-byte ABI word — it drops `count - 40` leading characters and
  /// TRAPS on any string shorter than 40 characters. This wraps the validating `init(hex:eip55:)`
  /// instead, which rejects malformed input by returning nil.
  internal static func parse(_ address: String) -> EthereumAddress? {
    try? EthereumAddress(hex: address, eip55: false)
  }
}

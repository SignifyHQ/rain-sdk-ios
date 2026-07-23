import Testing
import Foundation
@testable import RainCore

/// Codable coverage for `WalletTransaction.value`: JSON numbers decode straight into `Decimal`
/// (no `Double` round trip, so the synthesized encoder's full-precision output survives), strings
/// are strict-parsed (hex / partially numeric content throws instead of silently truncating), and
/// wrong JSON types throw instead of collapsing to `nil`.
@Suite("WalletTransaction Coding Tests")
struct WalletTransactionCodingTests {

  /// Minimal valid JSON with `valueFragment` spliced in as the `value` entry (omitted when nil).
  private static func json(valueFragment: String?) -> Data {
    let value = valueFragment.map { "\"value\": \($0)," } ?? ""
    return Data("""
    {
      "blockNum": "0x1",
      "uniqueId": "tx-1",
      "hash": "0xhash",
      "from": "0xfrom",
      \(value)
      "category": "external",
      "chainId": 1
    }
    """.utf8)
  }

  private static func decode(_ data: Data) throws -> WalletTransaction {
    try JSONDecoder().decode(WalletTransaction.self, from: data)
  }

  @Test("encode-then-decode preserves an 18-significant-digit value exactly")
  func roundTripFullPrecision() throws {
    let original = WalletTransaction(
      blockNum: "0x1",
      uniqueId: "tx-1",
      hash: "0xhash",
      from: "0xfrom",
      to: nil,
      value: Decimal(string: "1.123456789012345678"),
      erc721TokenId: nil,
      erc1155Metadata: nil,
      tokenId: nil,
      asset: "ETH",
      category: "external",
      rawContract: nil,
      metadata: nil,
      chainId: 1
    )

    let decoded = try Self.decode(JSONEncoder().encode(original))

    // The old path went JSON number → Double → printed form, which cannot represent all 19
    // significant digits; decoding as Decimal keeps the value exact.
    #expect(decoded.value == Decimal(string: "1.123456789012345678"))
    #expect(decoded == original)
  }

  @Test("a numeric string value decodes exactly")
  func numericStringDecodes() throws {
    let decoded = try Self.decode(Self.json(valueFragment: "\"1.123456789012345678\""))
    #expect(decoded.value == Decimal(string: "1.123456789012345678"))
  }

  @Test("decoding a hex string value throws instead of parsing partially")
  func hexStringThrows() {
    #expect(throws: DecodingError.self) {
      _ = try Self.decode(Self.json(valueFragment: "\"0x10\""))
    }
  }

  @Test("decoding a boolean value throws instead of collapsing to nil")
  func booleanValueThrows() {
    #expect(throws: DecodingError.self) {
      _ = try Self.decode(Self.json(valueFragment: "true"))
    }
  }

  @Test("an absent value decodes as nil")
  func absentValueDecodesNil() throws {
    let decoded = try Self.decode(Self.json(valueFragment: nil))
    #expect(decoded.value == nil)
  }

  @Test("a null value decodes as nil")
  func nullValueDecodesNil() throws {
    let decoded = try Self.decode(Self.json(valueFragment: "null"))
    #expect(decoded.value == nil)
  }
}

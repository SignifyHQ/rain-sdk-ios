import Testing
import Foundation
import Web3
@testable import RainCore

/// Strict hex parsing for money paths: malformed RPC payloads must throw instead of collapsing
/// to a silent zero balance or fee.
@Suite("EthereumConverter Tests")
struct EthereumConverterTests {

  @Test("parseHexToBigUIntStrict parses well-formed payloads exactly")
  func strictParsesWellFormedHex() throws {
    #expect(try EthereumConverter.parseHexToBigUIntStrict("0x0") == 0)
    // 1 ETH in wei.
    #expect(
      try EthereumConverter.parseHexToBigUIntStrict("0x0de0b6b3a7640000")
        == BigUInt(1_000_000_000_000_000_000)
    )
  }

  @Test(
    "parseHexToBigUIntStrict throws internalLogicError on malformed or empty payloads",
    arguments: ["not-hex", "0xZZ", "", "0x"]
  )
  func strictThrowsOnMalformedHex(hex: String) {
    #expect(throws: RainSDKError.internalLogicError(details: "")) {
      _ = try EthereumConverter.parseHexToBigUIntStrict(hex)
    }
  }

  @Test("parseHexToDecimalStrict scales by token decimals and throws on malformed input")
  func strictDecimalScalesAndThrows() throws {
    #expect(try EthereumConverter.parseHexToDecimalStrict("0x0de0b6b3a7640000", decimals: 18) == 1)
    #expect(try EthereumConverter.parseHexToDecimalStrict("0x0", decimals: 6) == 0)
    #expect(throws: RainSDKError.internalLogicError(details: "")) {
      _ = try EthereumConverter.parseHexToDecimalStrict("0xZZ", decimals: 18)
    }
  }
}

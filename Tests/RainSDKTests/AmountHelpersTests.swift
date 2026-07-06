import Testing
import Foundation
import Web3
@testable import RainSDK

@Suite("AmountHelpers.toBaseUnits")
struct AmountHelpersTests {

  @Test("in-range amounts do not throw on the scale guard")
  func inRangeAmountsDoNotThrow() throws {
    #expect(throws: Never.self) { try AmountHelpers.toBaseUnits(amount: Decimal(string: "16.38")!, decimals: 6) }
    #expect(throws: Never.self) { try AmountHelpers.toBaseUnits(amount: Decimal(string: "26.83")!, decimals: 6) }
    #expect(throws: Never.self) { try AmountHelpers.toBaseUnits(amount: Decimal(string: "0.00019472")!, decimals: 18) }
  }

  @Test("amount with more decimal places than the token throws")
  func overPrecisionThrows() {
    #expect(throws: RainSDKError.invalidAmount(amount: "", reason: "")) {
      try AmountHelpers.toBaseUnits(amount: Decimal(string: "0.1234567")!, decimals: 6)
    }
  }

  @Test("converts a representable amount to exact base units")
  func exactBaseUnits() throws {
    let baseUnits = try AmountHelpers.toBaseUnits(amount: Decimal(string: "0.00019472")!, decimals: 18)
    #expect(baseUnits == BigUInt(194_720_000_000_000))
  }

  @Test("is exact where a Double multiply would truncate")
  func exactWhereDoubleDrifts() throws {
    // 16.38 * 1e6 in Double == 16_379_999.999… -> the old BigUInt(Double) truncated to 16_379_999.
    let baseUnits = try AmountHelpers.toBaseUnits(amount: Decimal(string: "16.38")!, decimals: 6)
    #expect(baseUnits == BigUInt(16_380_000))
  }

  @Test("zero converts to zero base units")
  func zeroConvertsToZero() throws {
    let baseUnits = try AmountHelpers.toBaseUnits(amount: 0, decimals: 18)
    #expect(baseUnits == BigUInt(0))
  }

  @Test("negative amount throws instead of trapping")
  func negativeAmountThrows() {
    #expect(throws: RainSDKError.invalidAmount(amount: "", reason: "")) {
      try AmountHelpers.toBaseUnits(amount: -1, decimals: 18)
    }
  }

  @Test("toHexString encodes large wei without trapping")
  func toHexStringDoesNotTrapOnLargeWei() {
    // 1e19 > Int64.max, so the old String(Int(self), radix: 16) trapped. 1e19 is an exact Double;
    // build the expected from a radix-10 string (the bare literal would overflow Int at compile time).
    let expected = "0x" + String(BigUInt("10000000000000000000", radix: 10)!, radix: 16)
    #expect((1e19).toHexString == expected)
    #expect((0.0).toHexString == "0x0")
  }
}

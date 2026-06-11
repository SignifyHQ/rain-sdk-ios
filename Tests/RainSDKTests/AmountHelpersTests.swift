import Testing
import Foundation
import Web3
@testable import RainSDK

@Suite("AmountHelpers.toBaseUnits")
struct AmountHelpersTests {

  @Test("in-range amounts do not throw on the scale guard")
  func inRangeAmountsDoNotThrow() throws {
    #expect(throws: Never.self) { try AmountHelpers.toBaseUnits(amount: 16.38, decimals: 6) }
    #expect(throws: Never.self) { try AmountHelpers.toBaseUnits(amount: 26.83, decimals: 6) }
    #expect(throws: Never.self) { try AmountHelpers.toBaseUnits(amount: 0.00019472, decimals: 18) }
  }

  @Test("amount with more decimal places than the token throws")
  func overPrecisionThrows() {
    #expect(throws: RainSDKError.self) {
      try AmountHelpers.toBaseUnits(amount: 0.1234567, decimals: 6)
    }
  }

  @Test("converts a representable amount to exact base units")
  func exactBaseUnits() throws {
    let baseUnits = try AmountHelpers.toBaseUnits(amount: 0.00019472, decimals: 18)
    #expect(baseUnits == BigUInt(194_720_000_000_000))
  }
}

import Testing
import Foundation
@testable import RainCore

@Suite("RainCollateralToken Tests")
struct RainCollateralTokenTests {
  private func token(balance: String) -> RainCollateralToken {
    RainCollateralToken(address: "0xtoken", balance: balance, exchangeRate: 1.0, advanceRate: 0.8)
  }

  @Test("balanceAmount parses well-formed decimal balances")
  func parsesWellFormedBalances() {
    #expect(token(balance: "12.5").balanceAmount == Decimal(string: "12.5"))
    #expect(token(balance: "0").balanceAmount == 0)
    #expect(token(balance: " 42 ").balanceAmount == 42)
  }

  @Test("balanceAmount is strict: malformed balances are nil, never a partial parse")
  func malformedBalancesAreNil() {
    // Decimal(string:) alone would take the longest valid prefix ("12abc" -> 12).
    #expect(token(balance: "12abc").balanceAmount == nil)
    #expect(token(balance: "0x10").balanceAmount == nil)
    #expect(token(balance: "").balanceAmount == nil)
    #expect(token(balance: "12.5.5").balanceAmount == nil)
  }
}

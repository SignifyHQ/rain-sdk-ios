import Foundation
import Web3

/// Utility functions for amount conversion and validation
final class AmountHelpers {
  /// Rounds toward zero with no fractional digits; given the scale guard the scaled value is
  /// already integral, so this only acts as a defensive no-op.
  private static let roundDownBehavior = NSDecimalNumberHandler(
    roundingMode: .down,
    scale: 0,
    raiseOnExactness: false,
    raiseOnOverflow: false,
    raiseOnUnderflow: false,
    raiseOnDivideByZero: false
  )

  /// Converts a decimal amount (Double) to BigUInt (Wei/Base Units) with precision safety.
  /// Throws an error if the amount has more decimal places than the token allows.
  static func toBaseUnits(amount: Double, decimals: Int) throws -> BigUInt {
    // Exact Double→Decimal via the printed form (never Decimal(aDouble), which captures float error).
    let amountDecimal = Decimal(string: String(amount)) ?? 0
    let scale = max(0, -amountDecimal.exponent)

    if scale > decimals {
      throw RainSDKError.internalLogicError(
        details: "Amount scale (\(scale)) exceeds token decimals (\(decimals))"
      )
    }

    // Scale by 10^decimals on Decimal (exact base-10), not a Double multiply.
    let scaled = NSDecimalNumber(decimal: amountDecimal)
      .multiplying(byPowerOf10: Int16(decimals), withBehavior: roundDownBehavior)

    guard let baseUnits = BigUInt(scaled.stringValue, radix: 10) else {
      throw RainSDKError.internalLogicError(
        details: "Amount (\(amount)) could not be converted to base units: \"\(scaled.stringValue)\""
      )
    }

    return baseUnits
  }
}

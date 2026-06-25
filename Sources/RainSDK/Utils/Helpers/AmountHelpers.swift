import Foundation
import Web3

/// Utility functions for amount conversion and validation
public enum AmountHelpers {
  /// Rounds toward zero with no fractional digits. Given the scale guard the scaled value is
  /// already integral, so this only ever acts as a defensive no-op (and keeps the string output
  /// free of a decimal point or exponent).
  private static let roundDownBehavior = NSDecimalNumberHandler(
    roundingMode: .down,
    scale: 0,
    raiseOnExactness: false,
    raiseOnOverflow: false,
    raiseOnUnderflow: false,
    raiseOnDivideByZero: false
  )

  /// Converts a human-readable `Decimal` amount to `BigUInt` base units (wei) with precision safety.
  /// Throws `RainSDKError.invalidAmount` if the amount has more decimal places than the token allows,
  /// or cannot be represented as non-negative base units.
  public static func toBaseUnits(
    amount: Decimal,
    decimals: Int
  ) throws -> BigUInt {
    let scale = max(0, -amount.exponent)

    if scale > decimals {
      throw RainSDKError.invalidAmount(
        amount: "\(amount)",
        reason: "amount has \(scale) decimal places but the token supports \(decimals)"
      )
    }

    // Scale by 10^decimals on Decimal (exact base-10)
    let scaled = NSDecimalNumber(decimal: amount)
      .multiplying(byPowerOf10: Int16(decimals), withBehavior: roundDownBehavior)

    guard let baseUnits = BigUInt(scaled.stringValue, radix: 10) else {
      throw RainSDKError.invalidAmount(
        amount: "\(amount)",
        reason: "could not be converted to base units (\"\(scaled.stringValue)\")"
      )
    }

    return baseUnits
  }
}

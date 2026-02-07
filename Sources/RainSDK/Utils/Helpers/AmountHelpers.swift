import Foundation
import Web3

/// Utility functions for amount conversion and validation
final class AmountHelpers {
  /// Converts a decimal amount (Double) to BigUInt (Wei/Base Units) with precision safety.
  /// Throws an error if the amount has more decimal places than the token allows.
  static func toBaseUnits(amount: Double, decimals: Int) throws -> BigUInt {
    let amountDecimal = Decimal(amount)
    let scale = max(0, -amountDecimal.exponent)
    
    if scale > decimals {
      throw RainSDKError.internalLogicError(
        details: "Amount scale (\(scale)) exceeds token decimals (\(decimals))"
      )
    }
    
    return BigUInt(amount * pow(10.0, Double(decimals)))
  }
}

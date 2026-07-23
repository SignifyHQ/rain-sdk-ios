import Foundation
import Web3

/// SOL <-> lamports conversion, mirroring `EthereumConverter`'s role for wei.
/// 1 SOL = 1e9 lamports; SOL therefore has 9 decimals (vs 18 for EVM native currencies).
internal enum SolanaConverter {
  static let solDecimals = 9
  static let lamportsPerSol: UInt64 = 1_000_000_000

  /// Converts a human-readable SOL amount to whole lamports, truncating any fraction below
  /// one lamport. Uses `Decimal` arithmetic to avoid binary floating-point drift
  /// (mirrors Android's `BigDecimal(sol.toString())`).
  /// - Throws: `RainSDKError.internalLogicError` if `sol` is negative or the
  ///   result overflows `UInt64`.
  static func solToLamports(_ sol: Decimal) throws -> UInt64 {
    guard sol >= 0 else {
      throw RainSDKError.internalLogicError(details: "SOL amount must be non-negative: \(sol)")
    }

    let lamportsDecimal = sol * Decimal(lamportsPerSol)
    // Round toward zero to whole lamports, matching BigDecimal.toBigInteger() truncation.
    var rounded = Decimal()
    var input = lamportsDecimal
    NSDecimalRound(&rounded, &input, 0, .down)

    let number = NSDecimalNumber(decimal: rounded)
    guard number.compare(NSDecimalNumber(value: UInt64.max)) != .orderedDescending else {
      throw RainSDKError.internalLogicError(details: "SOL amount overflows lamports: \(sol)")
    }
    return number.uint64Value
  }

  /// Formats raw lamports as a precise SOL `Decimal` (`lamports / 1e9`).
  static func lamportsToSol(_ lamports: BigUInt) -> Decimal {
    let raw = NSDecimalNumber(string: lamports.description)
    let divisor = NSDecimalNumber(mantissa: 1, exponent: Int16(solDecimals), isNegative: false)
    return raw.dividing(by: divisor).decimalValue
  }

  /// `UInt64` overload (e.g. lamports decoded from a transaction), avoiding a `BigUInt(UInt64)`
  /// conversion that is ambiguous once BigInt is in module scope.
  static func lamportsToSol(_ lamports: UInt64) -> Decimal {
    let raw = NSDecimalNumber(value: lamports)
    let divisor = NSDecimalNumber(mantissa: 1, exponent: Int16(solDecimals), isNegative: false)
    return raw.dividing(by: divisor).decimalValue
  }

  /// `lamportsToSol` as a `Double`. Deprecated: use `lamportsToSol(_:)`.
  @available(*, deprecated, message: "Use lamportsToSol(_:): Double loses precision above 2^53 lamports.")
  static func lamportsToSolDouble(_ lamports: BigUInt) -> Double {
    NSDecimalNumber(decimal: lamportsToSol(lamports)).doubleValue
  }

  /// `lamportsToSolDouble` for `UInt64` input. Deprecated: use ``lamportsToSol(_:)``.
  @available(*, deprecated, message: "Use lamportsToSol(_:): Double loses precision above 2^53 lamports.")
  static func lamportsToSolDouble(_ lamports: UInt64) -> Double {
    Double(lamports) / Double(lamportsPerSol)
  }
}

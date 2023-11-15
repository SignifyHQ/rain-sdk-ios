import Foundation

public extension Double {
  func roundTo0f() -> NSString {
    NSString(format: "%.0f", self)
  }
  
  func roundTo2f() -> NSString {
    NSString(format: "%.2f", self)
  }
  
  func roundTo3f() -> NSString {
    NSString(format: "%.3f", self)
  }
  
  func roundTo6f() -> NSString {
    NSString(format: "%.6f", self)
  }
  
  func calculatePercentage(value: Double, percentageVal: Double) -> Double {
    let val = value * percentageVal
    return val / 100.0
  }
  
  func roundTo3fStr() -> String {
    String(format: "%.3f", self)
  }
}

public extension Double {
  /// Returns a String USD display of the current value, using the desired amount of fraction digits and setting the `symbolPrefix` (if any).
  ///
  /// Examples:
  /// - value: 2.351, prefix: nil, minFractionDigits: 0, maxFractionDigits: 2     -> "2.35"
  /// - value: 2.345, prefix: "$", minFractionDigits: 0, maxFractionDigits: 2     -> "$2.35"
  /// - value: 2.1, prefix: nil, minFractionDigits: 2, maxFractionDigits: 2       -> "2.10"
  /// - value: 2.00, prefix: "€", minFractionDigits: 2, maxFractionDigits: 2      -> "€2.00"
  func formattedAmount(
    prefix: String? = nil,
    minFractionDigits: Int = 0,
    maxFractionDigits: Int = 2,
    absoluteValue: Bool = false
  ) -> String {
    let formatter = NumberFormatter.usdFormatter
    formatter.minimumFractionDigits = minFractionDigits
    formatter.maximumFractionDigits = maxFractionDigits
    let value = absoluteValue ? abs(self) : self
    guard let result = formatter.string(from: value) else {
      return ""
    }
    let prefix = prefix ?? ""
    return "\(prefix)\(result)"
  }
  
  /// Returns a String USD display of the current value
  /// - Parameter absoluteValue: Check if it is an absolute value
  /// - Returns: String
  func formattedUSDAmount(absoluteValue: Bool = false) -> String {
    let formatter = NumberFormatter.usdFormatter
    formatter.minimumFractionDigits = Constants.FractionDigitsLimit.fiat.minFractionDigits
    formatter.maximumFractionDigits = Constants.FractionDigitsLimit.fiat.maxFractionDigits
    let value = absoluteValue ? abs(self) : self
    guard let result = formatter.string(from: value) else {
      return String.empty
    }
    return "\(Constants.CurrencyUnit.usd.symbol)\(result)"
  }

  /// Returns a String crypto display of the current value
  /// - Parameter absoluteValue: Check if it is an absolute value
  /// - Returns: String
  func formattedCryptoAmount(absoluteValue: Bool = false) -> String {
    let formatter = NumberFormatter.usdFormatter
    formatter.minimumFractionDigits = Constants.FractionDigitsLimit.crypto.minFractionDigits
    formatter.maximumFractionDigits = Constants.FractionDigitsLimit.crypto.maxFractionDigits
    let value = absoluteValue ? abs(self) : self
    guard let result = formatter.string(from: value) else {
      return String.empty
    }
    return result
  }
}

private extension NumberFormatter {
  static var usdFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.roundingMode = .halfUp
    return formatter
  }()
}

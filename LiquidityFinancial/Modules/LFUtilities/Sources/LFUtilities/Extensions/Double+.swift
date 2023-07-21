import Foundation

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
}

private extension NumberFormatter {
  static var usdFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.roundingMode = .halfUp
    return formatter
  }()
  
  func string(from doubleValue: Double?) -> String? {
    if let doubleValue = doubleValue {
      return string(from: NSNumber(value: doubleValue))
    }
    return nil
  }
}

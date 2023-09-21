import Foundation

//swiftlint:disable number_separator
public extension Double {
  func transformedShort(maxDigits: Int = Int.max) -> String {
    var value = abs(Decimal(self))
    var suffix: String?
    let digits: Int
    var tooSmall = false
    
    switch value {
    case 0:
      digits = 0
    case 0 ..< 0.0000_0001:
      digits = 8
      value = 0.0000_0001
      tooSmall = true
    case 0.0000_0001 ..< 1:
      let zeroCount = fractionZeroCount(value: value, maxCount: 8)
      digits = min(maxDigits, zeroCount + 4, 8)
    case 1..<1.01:
      digits = 4
    case 1.01..<1.1:
      digits = 3
    case 1.1..<20:
      digits = 2
    case 20..<200:
      digits = 1
    case 200..<19_999.5:
      digits = 0
    case 19_999.5..<edge(6):
      (digits, value) = digitsAndValue(value: value, basePow: 3)
      suffix = "K"
    case edge(6)..<edge(9):
      (digits, value) = digitsAndValue(value: value, basePow: 6)
      suffix = "M"
    case edge(9)..<edge(12):
      (digits, value) = digitsAndValue(value: value, basePow: 9)
      suffix = "B"
    case edge(12)..<edge(15):
      (digits, value) = digitsAndValue(value: value, basePow: 12)
      suffix = "T"
    default:
      (digits, value) = digitsAndValue(value: value, basePow: 15)
      suffix = "Q"
    }
    let doubleValue = (value as NSDecimalNumber).doubleValue
    if let suffix = suffix {
      return "\(doubleValue.formattedAmount(prefix: "$", minFractionDigits: 2))\(suffix)"
    } else {
      return "\(doubleValue.formattedAmount(prefix: "$", minFractionDigits: 6))"
    }
  }
}

private extension Double {
  func digitsAndValue(value: Decimal, basePow: Int) -> (Int, Decimal) {
    let digits: Int
    
    switch value {
    case pow(10, basePow)..<(2 * pow(10, basePow + 1)): digits = 2
    case (2 * pow(10, basePow + 1))..<(2 * pow(10, basePow + 2)): digits = 1
    default: digits = 0
    }
    
    return (digits, value / pow(10, basePow))
  }
  
  func edge(_ power: Int) -> Decimal {
    pow(10, power) - (pow(10, power - 3) / 2)
  }
  
  func fractionZeroCount(value: Decimal, maxCount: Int) -> Int {
    guard value > 0 && value < 1 else {
      return 0
    }
    for count in 0..<maxCount {
      if value * pow(10, count + 1) >= 1 {
        return count
      }
    }
    return maxCount
  }
}

import Foundation

//swiftlint:disable number_separator
public extension Double {
  func transformedShort(maxDigits: Int = Int.max) -> String {
    var value = abs(Decimal(self))
    var suffix: String?
    
    switch value {
    case 0:
      break
    case 0 ..< 0.0000_0001:
      value = 0.0000_0001
    case 0.0000_0001 ..< 1:
      break
    case 1..<1.01:
      break
    case 1.01..<1.1:
      break
    case 1.1..<20:
      break
    case 20..<200:
      break
    case 200..<19_999.5:
      break
    case 19_999.5..<edge(6):
      (_, value) = digitsAndValue(value: value, basePow: 3)
      suffix = "K"
    case edge(6)..<edge(9):
      (_, value) = digitsAndValue(value: value, basePow: 6)
      suffix = "M"
    case edge(9)..<edge(12):
      (_, value) = digitsAndValue(value: value, basePow: 9)
      suffix = "B"
    case edge(12)..<edge(15):
      (_, value) = digitsAndValue(value: value, basePow: 12)
      suffix = "T"
    default:
      (_, value) = digitsAndValue(value: value, basePow: 15)
      suffix = "Q"
    }
    let doubleValue = (value as NSDecimalNumber).doubleValue
    if let suffix {
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
}

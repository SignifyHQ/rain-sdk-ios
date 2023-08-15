import Foundation

extension Int {
    /// Examples:
    /// 100,000     -> "100k"
    /// 100,900     -> "100,9k"
    /// 1,000,000   -> "1M"
    /// 1,680,000   -> "1,7M"
  var roundedWithAbbreviations: String {
    let number = Double(self)
    let thousand = number / 1_000
    let million = number / 1_000_000
    if million >= 1.0 {
      return "\(round(million * 10) / 10)M"
    } else if thousand >= 1.0 {
      return "\(round(thousand * 10) / 10)k"
    } else {
      return "\(self)"
    }
  }
}

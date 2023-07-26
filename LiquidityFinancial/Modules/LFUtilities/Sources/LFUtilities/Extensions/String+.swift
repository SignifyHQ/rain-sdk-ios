import SwiftUI

// MARK: - Transform Extension
public extension String {
  func trimWhitespacesAndNewlines() -> String {
    trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  var plainPhoneString: String {
    let numbersOnly = CharacterSet(charactersIn: Constants.Default.numberCharacters.rawValue)
    let filteredPhone = filter { char -> Bool in
      char.unicodeScalars.contains(where: { numbersOnly.contains($0) })
    }
    return filteredPhone
  }
}

public extension String {
  func formattedAmount(
    prefix: String? = nil,
    minFractionDigits: Int = 0,
    maxFractionDigits: Int = 2,
    absoluteValue: Bool = false
  ) -> String {
    asDouble?.formattedAmount(
      prefix: prefix,
      minFractionDigits: minFractionDigits,
      maxFractionDigits: maxFractionDigits,
      absoluteValue: absoluteValue
    ) ?? ""
  }
  
  func withQuotes() -> String {
    "\"\(self)\""
  }

  func isValidEmail() -> Bool {
    let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-za-z]{2,64}"
    let pred = NSPredicate(format: "SELF MATCHES %@", regex)
    return pred.evaluate(with: self)
  }

  func replace(string: String, replacement: String) -> String {
    replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
  }

  func removeWhitespace() -> String {
    replace(string: " ", replacement: "")
  }

  func removeDollarSign() -> String {
    replace(string: "$", replacement: "").trimWhitespacesAndNewlines()
  }

  func removeDollarComma() -> String {
    replace(string: ",", replacement: "").trimWhitespacesAndNewlines()
  }

  func removeGroupingSeparator(locale: Locale = Locale.current) -> String {
    let groupingSeparator = locale.groupingSeparator ?? ","
    return replace(string: groupingSeparator, replacement: "").trimWhitespacesAndNewlines()
  }

  func convertToDecimalFormat(locale: Locale = Locale.current) -> String {
    let decimalSeparator = locale.decimalSeparator ?? "."
    if decimalSeparator != "." {
      return replace(string: decimalSeparator, replacement: ".")
    }
    return self
  }

  func widthOfString(usingFont font: UIFont) -> CGFloat {
    let fontAttributes = [NSAttributedString.Key.font: font]
    return (self as NSString).size(withAttributes: fontAttributes).width
  }

  var localizedString: String {
    NSLocalizedString(self, comment: "")
  }

  static func mimeType(for data: Data) -> String {
    var byte: UInt8 = 0
    data.copyBytes(to: &byte, count: 1)

    switch byte {
    case 0xFF:
      return "image/jpeg"
    case 0x89:
      return "image/png"
    case 0x47:
      return "image/gif"
    case 0x4D,
         0x49:
      return "image/tiff"
    case 0x25:
      return "application/pdf"
    case 0xD0:
      return "application/vnd"
    case 0x46:
      return "text/plain"
    default:
      return "application/octet-stream"
    }
  }

  func convertJsonStringToDictionary() -> [String: Any]? {
    if let data = data(using: .utf8) {
      let resultDic = data.convertToJsonDictionary()
      return resultDic
    }
    return nil
  }

  func versionCompare(_ otherVersion: String) -> ComparisonResult {
    let versionDelimiter = "."

    var versionComponents = components(separatedBy: versionDelimiter) // <1>
    var otherVersionComponents = otherVersion.components(separatedBy: versionDelimiter)

    let zeroDiff = versionComponents.count - otherVersionComponents.count // <2>

    if zeroDiff == 0 { // <3>
      // Same format, compare normally
      return compare(otherVersion, options: .numeric)
    } else {
      let zeros = Array(repeating: "0", count: abs(zeroDiff)) // <4>
      if zeroDiff > 0 {
        otherVersionComponents.append(contentsOf: zeros) // <5>
      } else {
        versionComponents.append(contentsOf: zeros)
      }
      return versionComponents.joined(separator: versionDelimiter)
        .compare(otherVersionComponents.joined(separator: versionDelimiter), options: .numeric) // <6>
    }
  }
}

public extension String {
  var asDouble: Double? {
    Double(self)
  }

  var nilIfEmpty: String? {
    isEmpty ? nil : self
  }

  static let empty: String = ""
}

public extension String? {
  var isNotNil: Bool {
    self != nil
  }
}

public extension String {
  /// Returns a user friendly version of the current id, by only keeping the characters after the last `-`.
  ///
  /// Example: "txn-a006a5e0-f03e-4c47-be59-331e8652227f" -> "331e8652227f
  var userFriendlyId: String {
    if let last = split(separator: "-").last {
      return String(last)
    }
    return self
  }

  func snakeCased() -> String? {
    let pattern = "([a-z0-9])([A-Z])"

    let regex = try? NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: count)
    return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2").lowercased()
  }
}

public extension String {
  var urlEncoded: String {
    addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
  }
}

public extension String {
  func deletingPrefix(_ prefix: String) -> String {
    guard hasPrefix(prefix) else { return self }
    return String(dropFirst(prefix.count))
  }

  func deletingSuffix(_ prefix: String) -> String {
    guard hasSuffix(prefix) else { return self }
    return String(dropLast(prefix.count))
  }
}

public extension String {
  func serverToTransactionDisplay(includeYear: Bool = false) -> String {
    guard let dt = DateFormatter.server.date(from: self) else {
      return self
    }
    return includeYear ? DateFormatter.transactionDisplayFull.string(from: dt) : DateFormatter.transactionDisplayShort.string(from: dt)
  }
  
  var displayDate: String? {
    guard let date = DateFormatter.server.date(from: self) else {
      return nil
    }
    return DateFormatter.monthDayDisplay.string(from: date)
  }
  
}

extension Collection {
  func unfoldSubSequences(limitedTo maxLength: Int) -> UnfoldSequence<SubSequence, Index> {
    sequence(state: startIndex) { start in
      guard start < endIndex else { return nil }
      let end = index(start, offsetBy: maxLength, limitedBy: endIndex) ?? endIndex
      defer { start = end }
      return self[start ..< end]
    }
  }
}

public extension StringProtocol where Self: RangeReplaceableCollection {
  func inserting<S: StringProtocol>(separator: S, every count: Int) -> Self {
    .init(unfoldSubSequences(limitedTo: count).joined(separator: separator))
  }
}

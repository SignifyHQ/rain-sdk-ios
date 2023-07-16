import Foundation

// MARK: - Transform Extension
public extension String {
  func trimWhitespacesAndNewlines() -> String {
    trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  var plainPhoneString: String {
    let numbersOnly = CharacterSet(charactersIn: Constants.Default.numberCharacters.rawValue)
    let filteredPhone = filter { c -> Bool in
      c.unicodeScalars.contains(where: { numbersOnly.contains($0) })
    }
    return filteredPhone
  }
}

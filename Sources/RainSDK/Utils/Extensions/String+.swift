import Foundation

extension String {
  static let empty: String = ""
  
  func isValidHTTPURL() -> Bool {
    guard
      !self.isEmpty
    else {
      return false
    }
    
    guard
      let components = URLComponents(string: self)
    else {
      return false
    }
    
    let isValid = (components.scheme == "http" || components.scheme == "https")
      && components.host != nil
    return isValid
  }
  
  var asDouble: Double? {
    Double(self)
  }

  /// Returns the string with a leading `"0x"` or `"0X"` prefix removed.
  var strippingHexPrefix: String {
    (hasPrefix("0x") || hasPrefix("0X")) ? String(dropFirst(2)) : self
  }

  /// Lightweight syntactic check for a 20-byte Ethereum address: `0x`-optional,
  /// exactly 40 hex characters. Does not validate the checksum.
  var isValidEthereumAddress: Bool {
    let cleaned = strippingHexPrefix
    guard cleaned.count == 40 else { return false }
    return cleaned.allSatisfy(\.isHexDigit)
  }
}

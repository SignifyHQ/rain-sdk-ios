import Foundation

extension String {
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
}

import Foundation
import NetworkUtilities

public struct LoginParameters: Parameterable {
  let phoneNumber: String
  let code: String
  
  public init(phoneNumber: String, code: String) {
    self.phoneNumber = phoneNumber
    self.code = code
  }
}

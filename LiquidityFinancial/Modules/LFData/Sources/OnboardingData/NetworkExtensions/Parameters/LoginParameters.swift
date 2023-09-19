import Foundation
import NetworkUtilities

public struct LoginParameters: Parameterable {
  let phoneNumber: String
  let code: String
  let lastXId: String
  
  public init(phoneNumber: String, otpCode: String, lastID: String = "") {
    self.phoneNumber = phoneNumber
    self.code = otpCode
    self.lastXId = lastID
  }
}

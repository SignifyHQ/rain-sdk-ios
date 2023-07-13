import Foundation
import DataUtilities

public struct LoginParameters: Parameterable {
  let phoneNumber: String
  let code: String
  let productName: String?
  let identity: String?
  let secret: String?
  
  public init(phoneNumber: String, code: String, productName: String, identity: String, secret: String) {
    self.phoneNumber = phoneNumber
    self.code = code
    self.productName = productName
    self.identity = identity
    self.secret = secret
  }
  
  public init(phoneNumber: String, code: String) {
    self.phoneNumber = phoneNumber
    self.code = code
    self.productName = nil
    self.identity = nil
    self.secret = nil
  }
}

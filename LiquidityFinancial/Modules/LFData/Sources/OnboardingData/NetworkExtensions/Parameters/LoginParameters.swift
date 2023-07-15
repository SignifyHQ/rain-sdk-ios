import Foundation
import DataUtilities

public struct LoginParameters: Parameterable {
  let phoneNumber: String
  let code: String
  let productName: String
  
  public init(phoneNumber: String, code: String, productName: String) {
    self.phoneNumber = phoneNumber
    self.code = code
    self.productName = productName
  }
}

import Foundation
import NetworkUtilities

public struct OTPParameters: Parameterable {
  
  public let phoneNumber: String
  
  public init(phoneNumber: String) {
    self.phoneNumber = phoneNumber
  }
  
}

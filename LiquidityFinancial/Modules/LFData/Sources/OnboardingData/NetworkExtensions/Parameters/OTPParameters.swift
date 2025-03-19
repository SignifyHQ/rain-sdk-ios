import Foundation
import NetworkUtilities
import OnboardingDomain

public struct OTPParameters: Parameterable, OTPParametersEntity {
  
  public let phoneNumber: String
  
  public init(phoneNumber: String) {
    self.phoneNumber = phoneNumber
  } 
}

import Foundation
import NetworkUtilities
import OnboardingDomain

public struct OTPParameters: Parameterable, OTPParametersEntity {
  
  public let phoneNumber: String?
  public let email: String?
  
  public init(
    phoneNumber: String? = nil,
    email: String? = nil
  ) {
    self.phoneNumber = phoneNumber
    self.email = email
  }
  
  public var authMethod: AuthMethod {
    if email != nil {
      return .email
    } else {
      return .phoneNumber
    }
  }
  
  public enum AuthMethod {
    case phoneNumber
    case email
  }
}

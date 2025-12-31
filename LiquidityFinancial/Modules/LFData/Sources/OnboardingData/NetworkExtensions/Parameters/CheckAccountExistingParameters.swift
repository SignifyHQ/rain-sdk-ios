import Foundation
import NetworkUtilities
import OnboardingDomain

public struct CheckAccountExistingParameters: Parameterable, CheckAccountExistingParametersEntity {
  public var productId: String = NetworkUtilities.productID
  
  public var phone: String?
  public var email: String?
  
  public init(
    phoneNumber: String? = nil,
    email: String? = nil
  ) {
    self.phone = phoneNumber
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

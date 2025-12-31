import Foundation
import NetworkUtilities
import OnboardingDomain

public struct LoginParameters: Parameterable, LoginParametersEntity {
  public let phoneNumber: String?
  public let email: String?
  
  public let code: String
  
  public let lastXId: String?
  public let verification: Verification?
  
  public var verificationEntity: VerificationEntity? {
    verification
  }
  
  public init(
    phoneNumber: String? = nil,
    email: String? = nil,
    otpCode: String,
    lastID: String? = nil,
    verification: Verification? = nil
  ) {
    self.phoneNumber = phoneNumber
    self.email = email
    
    self.code = otpCode
    
    self.lastXId = lastID
    self.verification = verification
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

public struct Verification: Parameterable, VerificationEntity {
  public var type: String
  public var secret: String
  
  public init(
    type: String,
    secret: String
  ) {
    self.type = type
    self.secret = secret
  }
}

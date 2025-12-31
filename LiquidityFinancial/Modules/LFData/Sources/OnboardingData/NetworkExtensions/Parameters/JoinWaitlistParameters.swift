import Foundation
import NetworkUtilities
import OnboardingDomain

public struct JoinWaitlistParameters: Parameterable, JoinWaitlistParametersEntity {
  public var countryCode: String
  public var stateCode: String?
  public var firstName: String
  public var lastName: String
  public var email: String
  
  public init(
    countryCode: String,
    stateCode: String? = nil,
    firstName: String,
    lastName: String,
    email: String
  ) {
    self.countryCode = countryCode
    self.stateCode = stateCode
    self.firstName = firstName
    self.lastName = lastName
    self.email = email
  }
}

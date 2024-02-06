import Foundation
import OnboardingDomain

public struct TestAPIOtp: Codable {
  public let requiredAuth: [String]
  
  public init(requiredAuth: [String]) {
    self.requiredAuth = requiredAuth
  }
}

extension TestAPIOtp: OtpEntity {}

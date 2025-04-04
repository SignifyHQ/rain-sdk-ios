import Foundation
import NetworkUtilities
import OnboardingDomain

public struct UnsupportedStateParameters: Parameterable, UnsupportedStateParametersEntity {
  public var countryCode: String
  
  public init(countryCode: String) {
    self.countryCode = countryCode
  }
}

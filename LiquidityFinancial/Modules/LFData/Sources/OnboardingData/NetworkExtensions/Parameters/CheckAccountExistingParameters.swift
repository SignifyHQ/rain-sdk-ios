import Foundation
import NetworkUtilities
import OnboardingDomain

public struct CheckAccountExistingParameters: Parameterable, CheckAccountExistingParametersEntity {
  public var phone: String
  public var productId: String = NetworkUtilities.productID
  
  public init(phoneNumber: String) {
    self.phone = phoneNumber
  }
}

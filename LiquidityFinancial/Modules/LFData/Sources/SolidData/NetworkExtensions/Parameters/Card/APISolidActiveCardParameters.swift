import Foundation
import SolidDomain
import NetworkUtilities

public struct APISolidActiveCardParameters: Parameterable, SolidActiveCardParametersEntity {
  public let expiryMonth: String
  public let expiryYear: String
  public let last4: String

  public init(expiryMonth: String, expiryYear: String, last4: String) {
    self.expiryMonth = expiryMonth
    self.expiryYear = expiryYear
    self.last4 = last4
  }
}

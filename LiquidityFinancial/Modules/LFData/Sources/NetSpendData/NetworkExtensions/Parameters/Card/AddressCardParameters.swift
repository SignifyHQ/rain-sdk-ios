import Foundation
import NetspendDomain
import NetworkUtilities

public struct AddressCardParameters: Parameterable, AddressCardParametersEntity {
  public let line1: String?
  public let line2: String?
  public let city: String?
  public let state: String?
  public let postalCode: String?
  public let country: String?
  
  public init(line1: String?, line2: String?, city: String?, state: String?, country: String?, postalCode: String?) {
    self.line1 = line1
    self.line2 = line2
    self.city = city
    self.state = state
    self.postalCode = postalCode
    self.country = country
  }
}

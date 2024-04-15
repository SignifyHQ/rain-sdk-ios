import Foundation
import NetworkUtilities
import RainDomain

public struct RainAddressParameters: Parameterable, RainAddressParametersEntity {
  public let line1: String
  public let line2: String?
  public let city: String
  public let region: String
  public let postalCode: String
  public let countryCode: String
  public let country: String
  
  public init(
    line1: String,
    line2: String?,
    city: String,
    region: String,
    postalCode: String,
    countryCode: String,
    country: String
  ) {
    self.line1 = line1
    self.line2 = line2
    self.city = city
    self.region = region
    self.postalCode = postalCode
    self.countryCode = countryCode
    self.country = country
  }
}

import Foundation
import NetworkUtilities
import RainDomain


public struct APIRainOrderCardParameters: Parameterable, RainOrderCardParametersEntity {
  public let shippingAddress: APIRainShippingAddressParameters
  
  public var shippingAddressEntity: RainDomain.RainShippingAddressParametersEntity {
    shippingAddress
  }
  
  public init(shippingAddress: APIRainShippingAddressParameters) {
    self.shippingAddress = shippingAddress
  }
}

public struct APIRainShippingAddressParameters: Parameterable, RainShippingAddressParametersEntity {
  public var line1: String
  public var line2: String?
  public var city: String
  public var region: String
  public var postalCode: String
  public var countryCode: String
  public var country: String
  
  public init(
    line1: String,
    line2: String? = nil,
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

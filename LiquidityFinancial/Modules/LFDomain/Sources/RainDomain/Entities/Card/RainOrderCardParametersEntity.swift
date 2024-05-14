import Foundation

// sourcery: AutoMockable
public protocol RainOrderCardParametersEntity {
  var shippingAddressEntity: RainShippingAddressParametersEntity { get }
}

// sourcery: AutoMockable
public protocol RainShippingAddressParametersEntity {
  var line1: String { get }
  var line2: String? { get }
  var city: String { get }
  var region: String { get }
  var postalCode: String { get }
  var countryCode: String { get }
  var country: String { get }
}

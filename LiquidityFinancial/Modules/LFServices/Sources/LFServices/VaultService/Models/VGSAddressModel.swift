import Foundation

public struct VGSAddressModel: Codable {
  var addressType: String?
  var line1: String?
  var line2: String?
  var city: String?
  var state: String?
  var country: String?
  var postalCode: String?
  
  public init(
    addressType: String? = nil,
    line1: String? = nil,
    line2: String? = nil,
    city: String? = nil,
    state: String? = nil,
    country: String? = nil,
    postalCode: String? = nil
  ) {
    self.addressType = addressType
    self.line1 = line1
    self.line2 = line2
    self.city = city
    self.state = state
    self.country = country
    self.postalCode = postalCode
  }
}

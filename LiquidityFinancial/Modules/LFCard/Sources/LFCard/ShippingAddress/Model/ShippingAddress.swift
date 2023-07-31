import Foundation
import OnboardingData
import CommonDomain

struct ShippingAddress {
  let line1: String
  let line2: String?
  let city: String
  let state: String
  let postalCode: String
  let country: String?
  
  var description: String {
    "\(line1) \(line2 ?? ""), \(city), \(state) - \(postalCode)"
  }
}

extension ShippingAddress {
  
  init(addressEntity: AddressEntity) {
    self.line1 = addressEntity.line1 ?? ""
    self.line2 = addressEntity.line2
    self.city = addressEntity.city ?? ""
    self.state = addressEntity.state ?? ""
    self.postalCode = addressEntity.postalCode ?? ""
    self.country = addressEntity.country
  }
}

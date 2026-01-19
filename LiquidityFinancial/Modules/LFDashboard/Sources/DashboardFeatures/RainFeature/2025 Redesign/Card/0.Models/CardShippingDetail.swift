import RainDomain
import LFUtilities
import Foundation
import BaseOnboarding

struct CardShippingDetail {
  let externalCardID: String?
  let line1: String?
  let line2: String?
  let city: String?
  let region: String?
  let postalCode: String?
  let countryCode: String?
  let country: String?
  let phoneNumber: String?
  let method: String?
  let createdAt: String?
  let updatedAt: String?
  
  init(entity: RainCardShippingAddressEntity) {
    self.externalCardID = entity.externalCardID
    self.line1 = entity.line1
    self.line2 = entity.line2
    self.city = entity.city
    self.region = entity.region
    self.postalCode = entity.postalCode
    self.countryCode = entity.countryCode
    self.country = entity.country
    self.phoneNumber = entity.phoneNumber
    self.method = entity.method
    self.createdAt = entity.createdAt
    self.updatedAt = entity.updatedAt
  }
  // Below init is only used to map the shipping address of a card order
  // and show the shipping details in the shipping details screen
  init(
    shippingAddress: ShippingAddress
  ) {
    self.line1 = shippingAddress.line1
    self.line2 = shippingAddress.line2
    self.city = shippingAddress.city
    self.region = shippingAddress.state
    self.postalCode = shippingAddress.postalCode
    self.countryCode = shippingAddress.country.rawValue
    self.country = shippingAddress.country.title
    
    self.externalCardID = nil
    self.phoneNumber = nil
    self.method = nil
    self.createdAt = nil
    self.updatedAt = nil
  }
}

// MARK: Helpers
extension CardShippingDetail {
  var createdAtDate: Date? {
    if let createdAt = createdAt,
       let format = LiquidityDateFormatter.getDateFormat(from: createdAt),
       let date = format.parseToDate(from: createdAt) {
      return date
    }
    return nil
  }
  
  func toShippingAddress() -> ShippingAddress {
    ShippingAddress(
      line1: line1 ?? "",
      line2: line2 ?? "",
      city: city ?? "",
      state: region ?? "",
      postalCode: postalCode ?? "",
      country: Country(title: country ?? "") ?? .US,
      requiresVerification: false
    )
  }
}

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

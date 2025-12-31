import Foundation
import RainDomain

public struct APIRainCardShippingAddress: Decodable {
  public let externalCardID: String?
  public let line1: String?
  public let line2: String?
  public let city: String?
  public let region: String?
  public let postalCode: String?
  public let countryCode: String?
  public let country: String?
  public let phoneNumber: String?
  public let method: String?
  public let createdAt: String?
  public let updatedAt: String?
}

extension APIRainCardShippingAddress: RainCardShippingAddressEntity {}

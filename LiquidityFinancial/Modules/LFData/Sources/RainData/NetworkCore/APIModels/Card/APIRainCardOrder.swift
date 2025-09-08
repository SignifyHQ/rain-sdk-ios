import Foundation
import RainDomain

public struct APIRainCardOrder: Decodable {
  public var id: String?
  public var userId: String
  public var status: String
  public var phoneNumber: String
  public var line1: String
  public var line2: String
  public var city: String
  public var region: String
  public var postalCode: String
  public var countryCode: String
  public var country: String
}

extension APIRainCardOrder: RainCardOrderEntity {}

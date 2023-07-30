import Foundation
import CardDomain

public struct APICard: Decodable {
  public let id: String
  public let expirationMonth: Int
  public let expirationYear: Int
  public let panLast4: String
  public let encryptedData: String?
  public let type: String
  public let status: String
  public let statusReason: String
  public let lockStatus: String
  public let unlockTime: String?
  public let shippingAddress: APIShippingAddress?
}

public struct APIShippingAddress: Decodable, ShippingAddressEntity {
  public let shippingStatus: String
  public let shipmentDate: String?
  public let estimatedArrivalDate: String?
  public let trackingNumber: String
  public let shippingvendor: String
}

import Foundation
import NetspendDomain
import NetspendSdk
import LFUtilities

public struct NSAPICard: Decodable {
  public let netspendCardId: String
  public let liquidityCardId: String
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
  
  public static func decodeData(session: NetspendSdkUserSession, encryptedData: String?) -> APICardEncrypted? {
    guard let encryptedData, let jsonStr = try? session.decryptWithJWKSet(value: encryptedData).jsonString else { return nil }
    return try? APICardEncrypted(jsonStr)
  }
}

public struct APIShippingAddress: Decodable, ShippingAddressEntity {
  public let shippingStatus: String
  public let shipmentDate: String?
  public let estimatedArrivalDate: String?
  public let trackingNumber: String?
  public let shippingVendor: String?
}

public struct APICardEncrypted: CardEncryptedEntity, Decodable {
  public let pan: String
  public let cvv2: String
  
  init(data: Data) throws {
    self = try JSONDecoder().decode(APICardEncrypted.self, from: data)
  }
  
  init(_ json: String, using encoding: String.Encoding = .utf8) throws {
    guard let data = json.data(using: encoding) else {
      throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
    }
    try self.init(data: data)
  }
}

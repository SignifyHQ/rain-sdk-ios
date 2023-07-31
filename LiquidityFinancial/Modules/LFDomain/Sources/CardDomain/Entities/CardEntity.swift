import Foundation
import NetspendSdk

public protocol CardEntity {
  var id: String { get }
  var expirationMonth: Int { get }
  var expirationYear: Int { get }
  var panLast4: String { get }
  var encryptedData: String? { get }
  var type: String { get }
  var status: String { get }
  var statusReason: String { get }
  var lockStatus: String { get }
  var unlockTime: String? { get }
  var shippingAddressEntity: ShippingAddressEntity? { get }
  func decodeData<T: CardEncryptedEntity>(session: NetspendSdkUserSession) -> T?
}

public protocol ShippingAddressEntity {
  var shippingStatus: String { get }
  var shipmentDate: String? { get }
  var estimatedArrivalDate: String? { get }
  var trackingNumber: String? { get }
  var shippingVendor: String { get }
}

public protocol CardEncryptedEntity {
  var pan: String { get }
  var cvv2: String { get }
}

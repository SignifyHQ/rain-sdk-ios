import Foundation

// sourcery: AutoMockable
public protocol NSCardEntity {
  var netspendCardId: String { get }
  var liquidityCardId: String { get }
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
}

// sourcery: AutoMockable
public protocol ShippingAddressEntity {
  var shippingStatus: String { get }
  var shipmentDate: String? { get }
  var estimatedArrivalDate: String? { get }
  var trackingNumber: String? { get }
  var shippingVendor: String? { get }
}

// sourcery: AutoMockable
public protocol CardEncryptedEntity {
  var pan: String { get }
  var cvv2: String { get }
}

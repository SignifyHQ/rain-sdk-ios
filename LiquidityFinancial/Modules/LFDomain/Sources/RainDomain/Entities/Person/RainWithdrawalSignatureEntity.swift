import Foundation

// sourcery: AutoMockable
public protocol RainWithdrawalSignatureEntity {
  var status: String { get }
  var retryAfterSeconds: Int? { get}
  var signatureEntity: RainSignatureEntity? { get }
  var expiresAt: String? { get }
}

public protocol RainSignatureEntity {
  var data: String { get }
  var salt: String { get }
}

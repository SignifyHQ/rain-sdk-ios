import Foundation

// sourcery: AutoMockable
public protocol GetApplePayTokenEntity {
  var tokenEntities: [ApplePayTokenEntity] { get }
}

// sourcery: AutoMockable
public protocol ApplePayTokenEntity {
  var cardId: String? { get }
  var walletProvider: String? { get }
  var panReferenceId: String? { get }
  var tokenReferenceId: String? { get }
  var tokenStatus: String? { get }
}

// sourcery: AutoMockable
public protocol PostApplePayTokenEntity {
  var activationData: String? { get }
  var ephemeralPublicKey: String? { get }
  var encryptedCardData: String? { get }
}

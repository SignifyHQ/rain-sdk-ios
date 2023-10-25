import Foundation

// sourcery: AutoMockable
public protocol GetApplePayTokenEntity where Self: Decodable {
  associatedtype Token: ApplePayTokenEntity
  var tokens: [Token] { get }
}

public protocol ApplePayTokenEntity where Self: Decodable {
  var cardId: String? { get }
  var walletProvider: String? { get }
  var panReferenceId: String? { get }
  var tokenReferenceId: String? { get }
  var tokenStatus: String? { get }
}

public protocol PostApplePayTokenEntity where Self: Decodable {
  var activationData: String? { get }
  var ephemeralPublicKey: String? { get }
  var encryptedCardData: String? { get }
}

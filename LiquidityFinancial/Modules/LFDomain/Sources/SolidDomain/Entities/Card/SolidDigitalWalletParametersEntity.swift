import Foundation

// sourcery: AutoMockable
public protocol SolidDigitalWalletParametersEntity {
  var wallet: String { get }
  var applePayEntity: SolidApplePayParametersEntity { get }
}

// sourcery: AutoMockable
public protocol SolidApplePayParametersEntity {
  var deviceCert: String { get }
  var nonceSignature: String { get }
  var nonce: String { get }
}

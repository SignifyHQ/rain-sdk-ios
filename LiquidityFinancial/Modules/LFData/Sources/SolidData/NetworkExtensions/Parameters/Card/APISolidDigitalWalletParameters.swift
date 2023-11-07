import Foundation
import SolidDomain
import NetworkUtilities

public struct APISolidDigitalWalletParameters: Parameterable, SolidDigitalWalletParametersEntity {
  public let wallet: String
  public let applePay: APISolidApplePayWalletParameters
  
  public var applePayEntity: SolidDomain.SolidApplePayParametersEntity {
    applePay
  }

  public init(wallet: String, applePay: APISolidApplePayWalletParameters) {
    self.wallet = wallet
    self.applePay = applePay
  }
}

public struct APISolidApplePayWalletParameters: Parameterable, SolidApplePayParametersEntity {
  public let deviceCert: String
  public let nonceSignature: String
  public let nonce: String

  public init(deviceCert: String, nonceSignature: String, nonce: String) {
    self.deviceCert = deviceCert
    self.nonceSignature = nonceSignature
    self.nonce = nonce
  }
}

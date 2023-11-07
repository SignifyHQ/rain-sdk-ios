import Foundation

public protocol SolidCreateDigitalWalletUseCaseProtocol {
  func execute(cardID: String, parameters: SolidApplePayParametersEntity) async throws -> SolidDigitalWalletEntity
}

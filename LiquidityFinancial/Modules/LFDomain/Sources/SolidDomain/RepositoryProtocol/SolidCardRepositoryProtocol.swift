import Foundation

// sourcery: AutoMockable
public protocol SolidCardRepositoryProtocol {
  func getListCard() async throws -> [SolidCardEntity]
  func updateCardStatus(cardID: String, parameters: SolidCardStatusParametersEntity) async throws -> SolidCardEntity
  func closeCard(cardID: String) async throws -> Bool
  func createVGSShowToken(cardID: String) async throws -> SolidCardShowTokenEntity
  func createDigitalWalletLink(
    cardID: String,
    parameters: SolidApplePayParametersEntity
  ) async throws -> SolidDigitalWalletEntity
}

import Foundation

// sourcery: AutoMockable
public protocol SolidCardAPIProtocol {
  func getListCard() async throws -> [APISolidCard]
  func updateCardStatus(cardID: String, parameters: APISolidCardStatusParameters) async throws -> APISolidCard
  func closeCard(cardID: String) async throws -> Bool
  func createVGSShowToken(cardID: String) async throws -> APISolidCardShowToken
  func createDigitalWalletLink(cardID: String, parameters: APISolidApplePayWalletParameters) async throws -> APISolidDigitalWallet
}

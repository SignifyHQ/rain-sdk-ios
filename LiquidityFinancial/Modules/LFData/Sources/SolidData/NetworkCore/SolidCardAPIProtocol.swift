import Foundation

// sourcery: AutoMockable
public protocol SolidCardAPIProtocol {
  func getListCard() async throws -> [APISolidCard]
  func updateCardStatus(cardID: String, parameters: APISolidCardStatusParameters) async throws -> APISolidCard
  func closeCard(cardID: String) async throws -> Bool
  func createVGSShowToken(cardID: String) async throws -> APISolidCardShowToken
  func createDigitalWalletLink(cardID: String, parameters: APISolidApplePayWalletParameters) async throws -> APISolidDigitalWallet
  func createVirtualCard(accountID: String) async throws -> APISolidCard
  func createCardPinToken(cardID: String) async throws -> APISolidCardPinToken
  func updateRoundUpDonation(cardID: String, parameters: APISolidRoundUpDonationParameters) async throws -> APISolidCard
  func activeCard(cardID: String, parameters: APISolidActiveCardParameters) async throws -> APISolidCard
  func getCardLimits(cardID: String) async throws -> APISolidCardLimits
}

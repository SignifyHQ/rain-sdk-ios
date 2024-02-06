import Foundation
import AccountDomain

// sourcery: AutoMockable
public protocol SolidCardRepositoryProtocol {
  func getListCard(isContainClosedCard: Bool) async throws -> [SolidCardEntity]
  func updateCardStatus(cardID: String, parameters: SolidCardStatusParametersEntity) async throws -> SolidCardEntity
  func closeCard(cardID: String) async throws -> Bool
  func createVGSShowToken(cardID: String) async throws -> SolidCardShowTokenEntity
  func createDigitalWalletLink(
    cardID: String,
    parameters: SolidApplePayParametersEntity
  ) async throws -> SolidDigitalWalletEntity
  
  func createVirtualCard(accountID: String) async throws -> SolidCardEntity
  func updateRoundUpDonation(
    cardID: String,
    parameters: SolidRoundUpDonationParametersEntity
  ) async throws -> SolidCardEntity
  func createCardPinToken(cardID: String) async throws -> SolidCardPinTokenEntity
  func activeCard(cardID: String, parameters: SolidActiveCardParametersEntity) async throws -> SolidCardEntity
  func getCardLimits(cardID: String) async throws -> SolidCardLimitsEntity
  func updateCardName(cardID: String, parameters: SolidCardNameParametersEntity) async throws -> SolidCardEntity
  func getCardTransactions(parameters: SolidCardTransactionParametersEntity) async throws -> TransactionListEntity
}

import Foundation

public protocol NSExternalFundingRepositoryProtocol {
  func set(request: ExternalCardParametersEntity, sessionID: String) async throws -> ExternalCardEntity
  func getPinWheelToken(sessionID: String) async throws -> PinWheelTokenEntity
  func getACHInfo(sessionID: String) async throws -> ACHInfoEntity
  func getLinkedAccount(sessionId: String) async throws -> any LinkedSourcesEntity
  func deleteLinkedAccount(sessionId: String, sourceId: String, sourceType: String) async throws -> UnlinkBankEntity
  func newExternalTransaction(
    parameters: ExternalTransactionParametersEntity,
    type: ExternalTransactionTypeEntity,
    sessionId: String
  ) async throws -> ExternalTransactionResponseEntity
  func externalCardTransactionFee(
    parameters: ExternalTransactionParametersEntity,
    type: ExternalTransactionTypeEntity,
    sessionId: String
  ) async throws -> ExternalCardFeeEntity
  func verifyCard(sessionId: String, request: VerifyExternalCardParametersEntity) async throws -> VerifyExternalCardResponseEntity
  func getFundingStatus(sessionID: String) async throws -> any ExternalFundingsatusEntity
  func getCardRemainingAmount(sessionID: String, type: String) async throws -> [TransferLimitConfigEntity]
  func getBankRemainingAmount(sessionID: String, type: String) async throws -> [TransferLimitConfigEntity]
}

import Foundation

public protocol NSExternalFundingAPIProtocol {
  func set(request: ExternalCardParameters, sessionID: String) async throws -> APIExternalCard
  func getPinWheelToken(sessionID: String) async throws -> APIPinWheelToken
  func getACHInfo(sessionID: String) async throws -> APIACHInfo
  func getLinkedSources(sessionID: String) async throws -> APILinkedSourcesResponse
  func deleteLinkedSource(sessionId: String, sourceId: String, sourceType: String) async throws -> APIUnlinkBankResponse
  func newTransaction(parameters: ExternalTransactionParameters, type: ExternalTransactionType, sessionId: String) async throws -> APIExternalTransactionResponse
  func externalCardTransactionFee(
    parameters: ExternalTransactionParameters,
    type: ExternalTransactionType,
    sessionId: String
  ) async throws -> APIExternalCardFeeResponse
  func verifyCard(sessionId: String, cardId: String, amount: Double) async throws -> APIVerifyExternalCardResponse
  func getFundingStatus(sessionID: String) async throws -> APIExternalFundingsatus
  func getCardRemainingAmount(sessionID: String, type: String) async throws -> [APITransferLimitConfig]
  func getBankRemainingAmount(sessionID: String, type: String) async throws -> [APITransferLimitConfig]
}

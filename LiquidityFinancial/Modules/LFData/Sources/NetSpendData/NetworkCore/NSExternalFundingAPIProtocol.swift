import Foundation

public protocol NSExternalFundingAPIProtocol {
  func set(request: ExternalCardParameters, sessionID: String) async throws -> APIExternalCard
  func getPinWheelToken(sessionID: String) async throws -> APIPinWheelToken
  func getACHInfo(sessionID: String) async throws -> APIACHInfo
  func getLinkedSources(sessionID: String) async throws -> APILinkedSourcesResponse
  func deleteLinkedSource(sessionId: String, sourceId: String) async throws -> APIUnlinkBankResponse
  func newTransaction(parameters: ExternalTransactionParameters, type: ExternalTransactionType, sessionId: String) async throws -> APIExternalTransactionResponse
}

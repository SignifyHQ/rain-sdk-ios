import Foundation
import NetSpendDomain
import NetspendSdk

public class NSExternalFundingRepository: NSExternalFundingRepositoryProtocol {

  private let externalFundingAPI: NSExternalFundingAPIProtocol
  
  public init(externalFundingAPI: NSExternalFundingAPIProtocol) {
    self.externalFundingAPI = externalFundingAPI
  }
  
  public func set(request: ExternalCardParametersEntity, sessionID: String) async throws -> ExternalCardEntity {
    let request = ExternalCardParameters(
      month: request.expirationEntity.month,
      year: request.expirationEntity.year,
      nameOnCard: request.nameOnCard,
      nickname: request.nickname,
      postalCode: request.postalCode,
      encryptedData: request.encryptedData
    )
    return try await externalFundingAPI.set(request: request, sessionID: sessionID)
  }
  
  public func getPinWheelToken(sessionID: String) async throws -> PinWheelTokenEntity {
    try await externalFundingAPI.getPinWheelToken(sessionID: sessionID)
  }
  
  public func getACHInfo(sessionID: String) async throws -> NetSpendDomain.ACHInfoEntity {
    try await externalFundingAPI.getACHInfo(sessionID: sessionID)
  }
  
  public func getLinkedAccount(sessionId: String) async throws -> any LinkedSourcesEntity {
    try await externalFundingAPI.getLinkedSources(sessionID: sessionId)
  }
  
  public func deleteLinkedAccount(sessionId: String, sourceId: String) async throws -> UnlinkBankEntity {
    try await externalFundingAPI.deleteLinkedSource(sessionId: sessionId, sourceId: sourceId)
  }
}

extension APIUnlinkBankResponse: UnlinkBankEntity {}

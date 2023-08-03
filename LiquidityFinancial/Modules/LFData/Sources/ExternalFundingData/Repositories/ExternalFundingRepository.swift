import Foundation
import ExternalFundingDomain
import NetspendSdk

public class ExternalFundingRepository: ExternalFundingRepositoryProtocol {
  private let externalFundingAPI: ExternalFundingAPIProtocol
  
  public init(externalFundingAPI: ExternalFundingAPIProtocol) {
    self.externalFundingAPI = externalFundingAPI
  }
  
  public func set(request: ExternalCardParametersEntity, sessionID: String) async throws -> ExternalCardEntity {
    let request = ExternalCardParameters(
      month: request.expiration.month,
      year: request.expiration.year,
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
  
  public func getACHInfo(sessionID: String) async throws -> ExternalFundingDomain.ACHInfoEntity {
    try await externalFundingAPI.getACHInfo(sessionID: sessionID)
  }
}

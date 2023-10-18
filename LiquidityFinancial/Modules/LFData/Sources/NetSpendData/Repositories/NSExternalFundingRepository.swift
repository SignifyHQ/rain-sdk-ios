import LFUtilities
import BankDomain
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
  
  public func getACHInfo(sessionID: String) async throws -> BankDomain.ACHInfoEntity {
    try await externalFundingAPI.getACHInfo(sessionID: sessionID)
  }
  
  public func getLinkedAccount(sessionId: String) async throws -> any LinkedSourcesEntity {
    try await externalFundingAPI.getLinkedSources(sessionID: sessionId)
  }
  
  public func deleteLinkedAccount(sessionId: String, sourceId: String, sourceType: String) async throws -> UnlinkBankEntity {
    try await externalFundingAPI.deleteLinkedSource(sessionId: sessionId, sourceId: sourceId, sourceType: sourceType)
  }
  
  public func newExternalTransaction(
    parameters: ExternalTransactionParametersEntity,
    type: ExternalTransactionTypeEntity,
    sessionId: String
  ) async throws -> ExternalTransactionResponseEntity {
    let transactionParameters = ExternalTransactionParameters(
      amount: parameters.amount,
      sourceId: parameters.sourceId,
      sourceType: parameters.sourceType,
      m2mFeeRequestId: parameters.m2mFeeRequestId
    )
    let transactionType = ExternalTransactionType(rawValue: type.rawString) ?? .deposit
    return try await externalFundingAPI.newTransaction(
      parameters: transactionParameters,
      type: transactionType,
      sessionId: sessionId
    )
  }
  
  public func externalCardTransactionFee(
    parameters: ExternalTransactionParametersEntity,
    type: ExternalTransactionTypeEntity,
    sessionId: String
  ) async throws -> ExternalCardFeeEntity {
    let transactionParameters = ExternalTransactionParameters(
      amount: parameters.amount,
      sourceId: parameters.sourceId,
      sourceType: parameters.sourceType,
      m2mFeeRequestId: parameters.m2mFeeRequestId
    )
    let transactionType = ExternalTransactionType(rawValue: type.rawString) ?? .deposit
    return try await externalFundingAPI.externalCardTransactionFee(
      parameters: transactionParameters,
      type: transactionType,
      sessionId: sessionId
    )
  }
  
  public func verifyCard(sessionId: String, cardId: String, amount: Double) async throws -> VerifyExternalCardResponseEntity {
    try await externalFundingAPI.verifyCard(sessionId: sessionId, cardId: cardId, amount: amount)
  }
  
  public func verifyCard(sessionId: String, request: VerifyExternalCardParametersEntity) async throws -> VerifyExternalCardResponseEntity {
    try await externalFundingAPI.verifyCard(sessionId: sessionId, cardId: request.cardId, amount: request.transferAmount)
  }
  
  public func getFundingStatus(sessionID: String) async throws -> any ExternalFundingsatusEntity {
    try await externalFundingAPI.getFundingStatus(sessionID: sessionID)
  }
  
  public func getCardRemainingAmount(sessionID: String, type: String) async throws -> [TransferLimitConfigEntity] {
    try await externalFundingAPI.getCardRemainingAmount(sessionID: sessionID, type: type)
  }
  
  public func getBankRemainingAmount(sessionID: String, type: String) async throws -> [TransferLimitConfigEntity] {
    try await externalFundingAPI.getBankRemainingAmount(sessionID: sessionID, type: type)
  }
  
  public func createPlaidToken(accountId: String) async throws -> CreatePlaidTokenResponseEntity {
    throw LiquidityError.notSupport
  }
}

extension APIUnlinkBankResponse: UnlinkBankEntity {}

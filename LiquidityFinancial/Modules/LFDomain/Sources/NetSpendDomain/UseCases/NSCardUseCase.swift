import Foundation
  
public class NSCardUseCase: NSCardUseCaseProtocol {
  private let repository: NSCardRepositoryProtocol
  
  public init(repository: NSCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func getListCard() async throws -> [CardEntity] {
    try await repository.getListCard()
  }
  
  public func getCard(cardID: String, sessionID: String) async throws -> CardEntity {
    try await repository.getCard(cardID: cardID, sessionID: sessionID)
  }
  
  public func lockCard(cardID: String, sessionID: String) async throws -> CardEntity {
    try await repository.lockCard(cardID: cardID, sessionID: sessionID)
  }
  
  public func unlockCard(cardID: String, sessionID: String) async throws -> CardEntity {
    try await repository.unlockCard(cardID: cardID, sessionID: sessionID)
  }
  
  public func closeCard(reason: CloseCardReasonEntity, cardID: String, sessionID: String) async throws -> CardEntity {
    try await repository.closeCard(reason: reason, cardID: cardID, sessionID: sessionID)
  }
  
  public func orderPhysicalCard(address: AddressCardParametersEntity, sessionID: String) async throws -> CardEntity {
    try await repository.orderPhysicalCard(address: address, sessionID: sessionID)
  }
  
  public func verifyCVVCode(
    requestParam: VerifyCVVCodeParametersEntity,
    cardID: String,
    sessionID: String
  ) async throws -> VerifyCVVCodeEntity {
    try await repository.verifyCVVCode(verifyRequest: requestParam, cardID: cardID, sessionID: sessionID)
  }
  
  public func setPin(requestParam: SetPinRequestEntity, cardID: String, sessionID: String) async throws -> CardEntity {
    try await repository.setPin(requestParam: requestParam, cardID: cardID, sessionID: sessionID)
  }

  public func getApplePayToken(sessionId: String, cardId: String) async throws -> any GetApplePayTokenEntity {
    try await repository.getApplePayToken(sessionId: sessionId, cardId: cardId)
  }
  
  public func postApplePayToken(sessionId: String, cardId: String, bodyData: [String: Any]) async throws -> PostApplePayTokenEntity {
    try await repository.postApplePayToken(sessionId: sessionId, cardId: cardId, bodyData: bodyData)
  }
}

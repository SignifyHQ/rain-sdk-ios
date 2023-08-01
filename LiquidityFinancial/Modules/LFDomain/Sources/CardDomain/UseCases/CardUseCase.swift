import Foundation
  
public class CardUseCase: CardUseCaseProtocol {
  private let repository: CardRepositoryProtocol
  
  public init(repository: CardRepositoryProtocol) {
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
  
  public func orderPhysicalCard(address: PhysicalCardAddressEntity, sessionID: String) async throws -> CardEntity {
    try await repository.orderPhysicalCard(address: address, sessionID: sessionID)
  }
  
  public func verifyCVVCode(
    requestParam: VerifyCVVCodeRequestEntity,
    cardID: String,
    sessionID: String
  ) async throws -> VerifyCVVCodeResponseEntity {
    try await repository.verifyCVVCode(verifyRequest: requestParam, cardID: cardID, sessionID: sessionID)
  }
  
  public func setPin(requestParam: SetPinRequestEntity, cardID: String, sessionID: String) async throws -> CardEntity {
    try await repository.setPin(requestParam: requestParam, cardID: cardID, sessionID: sessionID)
  }
}

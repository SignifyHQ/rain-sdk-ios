import Foundation
import CommonDomain
  
public class CardUseCase: CardUseCaseProtocol {
  private let repository: CardRepositoryProtocol
  
  public init(repository: CardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func getListCard() async throws -> [CardEntity] {
    try await repository.getListCard()
  }
  
  public func lockCard(cardID: String, sessionID: String) async throws -> CardEntity {
    try await repository.lockCard(cardID: cardID, sessionID: sessionID)
  }
  
  public func unlockCard(cardID: String, sessionID: String) async throws -> CardEntity {
    try await repository.unlockCard(cardID: cardID, sessionID: sessionID)
  }
  
  public func orderPhysicalCard(address: AddressEntity, sessionID: String) async throws -> CardEntity {
    try await repository.orderPhysicalCard(address: address, sessionID: sessionID)
  }
}

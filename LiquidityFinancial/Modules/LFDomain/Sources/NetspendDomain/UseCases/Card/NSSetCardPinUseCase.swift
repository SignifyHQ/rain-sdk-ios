import Foundation

public class NSSetCardPinUseCase: NSSetCardPinUseCaseProtocol {
  private let repository: NSCardRepositoryProtocol
  
  public init(repository: NSCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(
    requestParam: SetPinRequestEntity,
    cardID: String,
    sessionID: String
  ) async throws -> CardEntity {
    try await repository.setPin(requestParam: requestParam, cardID: cardID, sessionID: sessionID)
  }
}

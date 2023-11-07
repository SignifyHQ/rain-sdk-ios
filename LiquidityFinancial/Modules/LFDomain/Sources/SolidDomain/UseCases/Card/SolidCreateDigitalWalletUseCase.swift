import Foundation
  
public class SolidCreateDigitalWalletUseCase: SolidCreateDigitalWalletUseCaseProtocol {
  
  private let repository: SolidCardRepositoryProtocol
  
  public init(repository: SolidCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cardID: String, parameters: SolidApplePayParametersEntity) async throws -> SolidDigitalWalletEntity {
    try await self.repository.createDigitalWalletLink(cardID: cardID, parameters: parameters)
  }
}

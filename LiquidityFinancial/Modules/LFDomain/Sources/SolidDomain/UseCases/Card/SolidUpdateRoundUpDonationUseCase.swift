import Foundation
  
public class SolidUpdateRoundUpDonationUseCase: SolidUpdateRoundUpDonationUseCaseProtocol {
  
  private let repository: SolidCardRepositoryProtocol
  
  public init(repository: SolidCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(cardID: String, parameters: SolidRoundUpDonationParametersEntity) async throws -> SolidCardEntity {
    try await self.repository.updateRoundUpDonation(cardID: cardID, parameters: parameters)
  }
}

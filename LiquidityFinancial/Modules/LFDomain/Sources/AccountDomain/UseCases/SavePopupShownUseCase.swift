import Foundation

public final class SavePopupShownUseCase: SavePopupShownUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(campaign: String) async throws {
    try await repository.savePopupShown(campaign: campaign)
  }
}

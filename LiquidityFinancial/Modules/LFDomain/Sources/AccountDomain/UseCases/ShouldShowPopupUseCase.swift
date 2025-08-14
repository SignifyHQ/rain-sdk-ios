import Foundation

public final class ShouldShowPopupUseCase: ShouldShowPopupUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(campaign: String) async throws -> ShouldShowPopupEntity {
    try await repository.shouldShowPopup(campaign: campaign)
  }
}

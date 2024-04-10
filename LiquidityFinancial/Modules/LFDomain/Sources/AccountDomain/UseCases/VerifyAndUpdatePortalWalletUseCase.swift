import Foundation

public final class VerifyAndUpdatePortalWalletUseCase: VerifyAndUpdatePortalWalletUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws {
    try await repository.verifyAndUpdatePortalWalletAddress()
  }
}

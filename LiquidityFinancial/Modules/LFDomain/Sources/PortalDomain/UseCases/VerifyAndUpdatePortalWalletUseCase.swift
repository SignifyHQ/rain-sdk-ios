import Foundation

public final class VerifyAndUpdatePortalWalletUseCase: VerifyAndUpdatePortalWalletUseCaseProtocol {
  
  private let repository: PortalRepositoryProtocol
  
  public init(repository: PortalRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws {
    try await repository.verifyAndUpdatePortalWalletAddress()
  }
}

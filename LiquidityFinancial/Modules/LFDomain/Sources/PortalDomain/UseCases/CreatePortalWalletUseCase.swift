import Foundation

public final class CreatePortalWalletUseCase: CreatePortalWalletUseCaseProtocol {
  private let repository: PortalRepositoryProtocol
  
  public init(repository: PortalRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> String {
    try await repository.createPortalWallet()
  }
}

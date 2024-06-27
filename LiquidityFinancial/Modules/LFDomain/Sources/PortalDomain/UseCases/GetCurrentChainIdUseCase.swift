import Foundation

public final class GetCurrentChainIdUseCase: GetCurrentChainIdUseCaseProtocol {
  private let repository: PortalRepositoryProtocol
  
  public init(repository: PortalRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() -> String {
    repository.chainId
  }
}

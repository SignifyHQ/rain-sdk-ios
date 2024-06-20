import Foundation

public final class SendEthUseCase: SendEthUseCaseProtocol {
  private let repository: PortalRepositoryProtocol
  
  public init(repository: PortalRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(to address: String, contractAddress: String?, amount: Double) async throws -> String {
    try await repository.send(to: address, contractAddress: contractAddress, amount: amount)
  }
}

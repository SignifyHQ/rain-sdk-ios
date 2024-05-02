import Foundation

public final class SendEthUseCase: SendEthUseCaseProtocol {
  private let repository: PortalRepositoryProtocol
  
  public init(repository: PortalRepositoryProtocol) {
    self.repository = repository
  }
  
  public func estimateFee(to address: String, contractAddress: String?, amount: Double) async throws -> Double {
    try await repository.estimateFee(to: address, contractAddress: contractAddress, amount: amount)
  }
  
  public func executeSend(to address: String, contractAddress: String?, amount: Double) async throws {
    try await repository.send(to: address, contractAddress: contractAddress, amount: amount)
  }
}

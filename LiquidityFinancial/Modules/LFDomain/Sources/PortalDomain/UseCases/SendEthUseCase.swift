import Foundation

public final class SendEthUseCase: SendEthUseCaseProtocol {
  private let repository: PortalRepositoryProtocol
  
  public init(repository: PortalRepositoryProtocol) {
    self.repository = repository
  }
  
  public func estimateFee(to address: String, amount: Double) async throws -> Double {
    try await repository.estimateFee(to: address, amount: amount)
  }
  
  public func executeSend(to address: String, amount: Double) async throws {
    try await repository.send(to: address, amount: amount)
  }
}

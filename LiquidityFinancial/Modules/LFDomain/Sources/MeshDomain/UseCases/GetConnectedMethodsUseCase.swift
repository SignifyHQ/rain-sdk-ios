import Foundation

public final class GetConnectedMethodsUseCase: GetConnectedMethodsUseCaseProtocol {
  private let repository: MeshRepositoryProtocol
  
  public init(repository: MeshRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> [MeshPaymentMethodEntity] {
    try await repository.getConnectedMethods()
  }
}

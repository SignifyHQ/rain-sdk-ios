import Foundation

public final class DeleteConnectedMethodUseCase: DeleteConnectedMethodUseCaseProtocol {
  private let repository: MeshRepositoryProtocol
  
  public init(repository: MeshRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(methodId: String) async throws {
    try await repository.deleteConnectedMethod(with: methodId)
  }
}

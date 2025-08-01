import Foundation

public final class LaunchMeshFlowUseCase: LaunchMeshFlowUseCaseProtocol {
  private let repository: MeshRepositoryProtocol
  
  public init(repository: MeshRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(methodId: String?) async throws {
    try await repository.launchMeshFlow(for: methodId)
  }
}

import Foundation

public protocol LaunchMeshFlowUseCaseProtocol {
  func execute(methodId: String?) async throws
}

import Foundation

// sourcery: AutoMockable
public protocol MeshRepositoryProtocol {
  func launchMeshFlow(for methodId: String?) async throws
  func getConnectedMethods() async throws -> [MeshPaymentMethodEntity]
  func deleteConnectedMethod(with methodId: String) async throws
}

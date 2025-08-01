import Foundation

// sourcery: AutoMockable
public protocol MeshAPIProtocol {
  func getLinkToken(for methodId: String?) async throws -> MeshLinkToken
  func getConnectedMethods() async throws -> [MeshPaymentMethod]
  func saveConnectedMethod(method: MeshConnection) async throws
  func deleteConnectedMethod(with methodId: String) async throws
}

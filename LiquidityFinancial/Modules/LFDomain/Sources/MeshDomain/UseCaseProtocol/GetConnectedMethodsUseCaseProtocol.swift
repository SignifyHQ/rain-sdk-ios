import Foundation

public protocol GetConnectedMethodsUseCaseProtocol {
  func execute() async throws -> [MeshPaymentMethodEntity]
}

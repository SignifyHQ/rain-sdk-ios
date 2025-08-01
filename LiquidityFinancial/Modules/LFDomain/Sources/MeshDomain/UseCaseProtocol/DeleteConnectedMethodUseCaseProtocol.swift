import Foundation

public protocol DeleteConnectedMethodUseCaseProtocol {
  func execute(methodId: String) async throws
}

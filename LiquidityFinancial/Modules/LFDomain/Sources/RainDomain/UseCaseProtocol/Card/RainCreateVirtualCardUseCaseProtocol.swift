import Foundation

public protocol RainCreateVirtualCardUseCaseProtocol {
  func execute() async throws -> RainCardEntity
}

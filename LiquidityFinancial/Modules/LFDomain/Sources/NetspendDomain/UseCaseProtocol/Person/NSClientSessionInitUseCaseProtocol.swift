import Foundation

public protocol NSClientSessionInitUseCaseProtocol {
  func execute() async throws -> NSJwkTokenEntity
}

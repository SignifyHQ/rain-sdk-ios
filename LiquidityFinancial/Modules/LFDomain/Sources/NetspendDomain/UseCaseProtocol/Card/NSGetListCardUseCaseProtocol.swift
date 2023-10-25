import Foundation

public protocol NSGetListCardUseCaseProtocol {
  func execute() async throws -> [CardEntity]
}

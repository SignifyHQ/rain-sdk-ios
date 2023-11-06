import Foundation

public protocol NSGetAccountDetailUseCaseProtocol {
  func execute(id: String) async throws -> NSAccountEntity
}

import Foundation

public protocol ZerohashGetAccountDetailUseCaseProtocol {
  func execute(id: String) async throws -> ZerohashAccountEntity
}

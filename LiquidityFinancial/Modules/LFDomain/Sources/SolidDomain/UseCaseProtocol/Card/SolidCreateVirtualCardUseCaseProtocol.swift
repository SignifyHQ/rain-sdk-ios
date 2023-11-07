import Foundation

public protocol SolidCreateVirtualCardUseCaseProtocol {
  func execute(accountID: String) async throws -> SolidCardEntity
}

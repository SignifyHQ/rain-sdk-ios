import Foundation

public protocol SolidUnlinkContactUseCaseProtocol {
  func execute(id: String) async throws -> SolidUnlinkContactResponseEntity
}

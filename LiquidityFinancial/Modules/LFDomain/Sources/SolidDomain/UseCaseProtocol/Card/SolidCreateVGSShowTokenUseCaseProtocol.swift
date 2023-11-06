import Foundation

public protocol SolidCreateVGSShowTokenUseCaseProtocol {
  func execute(cardID: String) async throws -> SolidCardShowTokenEntity
}

import Foundation

public protocol SolidCreateCardPinTokenUseCaseProtocol {
  func execute(cardID: String) async throws -> SolidCardPinTokenEntity
}

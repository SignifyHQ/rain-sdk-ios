import Foundation

public protocol SolidCloseCardUseCaseProtocol {
  func execute(cardID: String) async throws -> Bool
}

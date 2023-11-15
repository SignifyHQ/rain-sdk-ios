import Foundation

public protocol SolidGetCardLimitsUseCaseProtocol {
  func execute(cardID: String) async throws -> SolidCardLimitsEntity
}

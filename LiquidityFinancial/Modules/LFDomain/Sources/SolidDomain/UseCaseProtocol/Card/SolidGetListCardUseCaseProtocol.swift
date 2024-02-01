import Foundation

public protocol SolidGetListCardUseCaseProtocol {
  func execute(isContainClosedCard: Bool) async throws -> [SolidCardEntity]
}

import Foundation

public protocol SolidGetListCardUseCaseProtocol {
  func execute() async throws -> [SolidCardEntity]
}

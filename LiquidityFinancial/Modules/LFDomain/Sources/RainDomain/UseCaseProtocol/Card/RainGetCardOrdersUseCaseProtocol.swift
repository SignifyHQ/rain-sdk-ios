import Foundation

public protocol RainGetCardOrdersUseCaseProtocol {
  func execute() async throws -> [RainCardEntity]
}

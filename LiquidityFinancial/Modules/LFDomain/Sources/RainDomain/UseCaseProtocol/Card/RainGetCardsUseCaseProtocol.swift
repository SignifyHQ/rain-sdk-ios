import Foundation

public protocol RainGetCardsUseCaseProtocol {
  func execute() async throws -> [RainCardEntity]
}

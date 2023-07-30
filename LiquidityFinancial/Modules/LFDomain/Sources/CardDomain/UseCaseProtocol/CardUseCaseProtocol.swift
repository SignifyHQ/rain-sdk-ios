import Foundation

public protocol CardUseCaseProtocol {
  func getListCard() async throws -> [CardEntity]
}

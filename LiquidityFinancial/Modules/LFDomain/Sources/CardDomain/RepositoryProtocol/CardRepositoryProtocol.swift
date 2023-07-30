import Foundation

public protocol CardRepositoryProtocol {
  func getListCard() async throws -> [CardEntity]
}

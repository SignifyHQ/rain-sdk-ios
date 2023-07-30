import Foundation

public protocol CardAPIProtocol {
  func getListCard() async throws -> [APICard] // Consider create APIList[APICard]
}

import Foundation

// sourcery: AutoMockable
public protocol SolidCardRepositoryProtocol {
  func getListCard() async throws -> [SolidCardEntity]
}

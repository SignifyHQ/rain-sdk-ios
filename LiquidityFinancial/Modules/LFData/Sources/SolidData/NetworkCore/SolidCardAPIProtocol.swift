import Foundation

// sourcery: AutoMockable
public protocol SolidCardAPIProtocol {
  func getListCard() async throws -> [APISolidCard]
}

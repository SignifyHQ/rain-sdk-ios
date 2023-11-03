import Foundation

// sourcery: AutoMockable
public protocol SolidCardAPIProtocol {
  func getListCard() async throws -> [APISolidCard]
  func updateCardStatus(cardID: String, parameters: APISolidCardStatusParameters) async throws -> APISolidCard
  func closeCard(cardID: String) async throws -> Bool
}

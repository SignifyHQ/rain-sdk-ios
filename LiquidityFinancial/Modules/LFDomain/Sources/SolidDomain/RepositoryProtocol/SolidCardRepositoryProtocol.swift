import Foundation

// sourcery: AutoMockable
public protocol SolidCardRepositoryProtocol {
  func getListCard() async throws -> [SolidCardEntity]
  func updateCardStatus(cardID: String, parameters: SolidCardStatusParametersEntity) async throws -> SolidCardEntity
}

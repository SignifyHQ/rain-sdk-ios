import Foundation

public protocol SolidUpdateCardNameUseCaseProtocol {
  func execute(cardID: String, parameters: SolidCardNameParametersEntity) async throws -> SolidCardEntity
}

import Foundation

public protocol SolidUpdateCardStatusUseCaseProtocol {
  func execute(cardID: String, parameters: SolidCardStatusParametersEntity) async throws -> SolidCardEntity
}

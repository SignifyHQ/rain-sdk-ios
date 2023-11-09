import Foundation

public protocol SolidActiveCardUseCaseProtocol {
  func execute(cardID: String, parameters: SolidActiveCardParametersEntity) async throws -> SolidCardEntity
}

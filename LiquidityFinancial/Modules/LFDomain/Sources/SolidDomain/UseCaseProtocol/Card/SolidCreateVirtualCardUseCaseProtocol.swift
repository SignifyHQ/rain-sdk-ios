import Foundation

public protocol SolidCreateVirtualCardUseCaseProtocol {
  func execute(accountID: String, parameters: SolidCreateVirtualCardParametersEntity) async throws -> SolidCardEntity
}

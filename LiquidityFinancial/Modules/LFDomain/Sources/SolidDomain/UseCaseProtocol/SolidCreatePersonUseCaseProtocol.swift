import Foundation

public protocol SolidCreatePersonUseCaseProtocol {
  func execute(parameters: SolidPersonParametersEntity) async throws -> Bool
}

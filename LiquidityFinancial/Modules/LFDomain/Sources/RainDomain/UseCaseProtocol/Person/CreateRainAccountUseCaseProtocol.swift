import Foundation

public protocol CreateRainAccountUseCaseProtocol {
  func execute(parameters: RainPersonParametersEntity) async throws -> RainPersonEntity
}

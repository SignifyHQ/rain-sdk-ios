import Foundation

public protocol GetUnsupportedStatesUseCaseProtocol {
  func execute(parameters: UnsupportedStateParametersEntity) async throws -> [UnsupportedStateEntity]
}

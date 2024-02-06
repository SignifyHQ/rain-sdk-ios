import Foundation

public protocol ListFeatureFlagUseCaseProtocol {
  func execute() async throws -> ListFeatureFlagEntity
}

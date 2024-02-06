import Foundation

// sourcery: AutoMockable
public protocol FeatureFlagRepositoryProtocol {
  func list() async throws -> ListFeatureFlagEntity
}

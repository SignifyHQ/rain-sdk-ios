import Foundation
import FeatureFlagDomain

public protocol FeatureFlagAPIProtocol {
  func list() async throws -> APIListFeatureFlagResponse
}

import AuthorizationManager
import FeatureFlagDomain
import LFUtilities

public class FeatureFlagRepository: FeatureFlagRepositoryProtocol {
  
  private let featureFlagAPI: FeatureFlagAPIProtocol
  
  public init(featureFlagAPI: FeatureFlagAPIProtocol) {
    self.featureFlagAPI = featureFlagAPI
  }
  
  public func list() async throws -> APIListFeatureFlagResponse {
    try await featureFlagAPI.list()
  }
}

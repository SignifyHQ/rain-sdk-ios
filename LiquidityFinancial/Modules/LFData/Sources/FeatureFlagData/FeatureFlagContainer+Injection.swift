import Factory
import FeatureFlagDomain
import CoreNetwork
import AuthorizationManager

extension Container {
  public var featureFlagAPI: Factory<FeatureFlagAPIProtocol> {
    self {
      LFCoreNetwork<FeatureFlagRoute>()
    }
  }
  
  public var featureFlagRepository: Factory<FeatureFlagRepositoryProtocol> {
    self { FeatureFlagRepository(featureFlagAPI: self.featureFlagAPI.callAsFunction()) }
  }
}

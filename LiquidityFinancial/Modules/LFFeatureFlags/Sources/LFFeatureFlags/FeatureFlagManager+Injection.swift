import Foundation
import Factory

extension Container {
  
  public var featureFlagManager: Factory<FeatureFlagManagerProtocol> {
    self {
      FeatureFlagManager()
    }
    .singleton
  }
  
}

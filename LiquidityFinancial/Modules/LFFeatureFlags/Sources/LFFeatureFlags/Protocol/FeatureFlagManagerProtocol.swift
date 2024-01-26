import Foundation

public protocol FeatureFlagManagerProtocol {
  
  func fetchEnabledFeatureFlags()
  func isFeatureFlagEnabled(_ key: FeatureFlagKey) -> Bool
  
}

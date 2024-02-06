import Foundation
import Combine
import FeatureFlagDomain

public protocol FeatureFlagManagerProtocol {
  
  var featureFlagsSubject: CurrentValueSubject<[FeatureFlagEntity], Never> { get }
  
  func fetchEnabledFeatureFlags()
  func isFeatureFlagEnabled(_ key: FeatureFlagKey) -> Bool
  func signOut()
  
}

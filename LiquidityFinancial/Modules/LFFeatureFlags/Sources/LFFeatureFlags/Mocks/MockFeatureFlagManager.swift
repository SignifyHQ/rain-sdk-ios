import Combine
import FeatureFlagDomain

public class MockFeatureFlagManager: FeatureFlagManagerProtocol {
  public init() { }
  
  public var featureFlagsSubject = CurrentValueSubject<[FeatureFlagEntity], Never>([])
  
  public var fetchEnabledFeatureFlagsReturnValue: [MockFeatureFlagModel]?
  public var fetchEnabledFeatureFlagsCalled = false
  public var isFeatureFlagEnabledCalled = false
  public var signOutCalled = false
  
  public func fetchEnabledFeatureFlags() {
    fetchEnabledFeatureFlagsCalled = true
    
    if let model = fetchEnabledFeatureFlagsReturnValue  {
      featureFlagsSubject.send(model)
    }
  }
  
  public func isFeatureFlagEnabled(_ key: FeatureFlagKey) -> Bool {
    isFeatureFlagEnabledCalled = true
    if let models = fetchEnabledFeatureFlagsReturnValue  {
      return models.first(where: { $0.key == key.rawValue })?.enabled ?? false
    }
    return false
  }
  
  public func signOut() {
    signOutCalled = true
  }
}

public struct MockFeatureFlagModel: FeatureFlagEntity {
  public var id: String
  public var key: String
  public var productId: String?
  public var enabled: Bool
  public var description: String?
  
  public init() {
    self.id = ""
    self.key = ""
    self.productId = nil
    self.enabled = false
    self.description = ""
  }
  
  public init(id: String, key: String, productId: String? = nil, enabled: Bool, description: String? = nil) {
    self.id = id
    self.key = key
    self.productId = productId
    self.enabled = enabled
    self.description = description
  }
}

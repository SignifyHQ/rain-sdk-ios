import Foundation
import LFUtilities

public class MockEnvironmentService: EnvironmentServiceProtocol {
  
  public init() {}
  
  public var setNetworkEnvironmentCalled = false
  
  public var networkEnvironment: NetworkEnvironment = .productionTest {
    didSet {
      setNetworkEnvironmentCalled = true
    }
  }
  
  public func toggleEnvironment() {
    networkEnvironment = networkEnvironment == .productionTest ? .productionLive : .productionTest
  }
}

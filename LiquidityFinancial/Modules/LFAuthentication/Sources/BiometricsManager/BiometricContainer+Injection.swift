import Foundation
import Factory
import LocalAuthentication

extension Container {
  
  public var biometricsManager: Factory<BiometricsManagerProtocol> {
    self {
      BiometricsManager()
    }
    .singleton
  }
  
}

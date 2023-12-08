import Foundation
import Factory
import LocalAuthentication

extension Container {
  
  public var biometricsManager: Factory<BiometricsManagerProtocol> {
    Factory(self) {
      BiometricsManager(context: LAContext())
    }
  }
  
}

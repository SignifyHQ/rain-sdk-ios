import Foundation
import LFUtilities
import Factory

extension Container {
  public var environmentService: Factory<EnvironmentServiceProtocol> {
    Factory(self) {
      EnvironmentService()
    }.singleton
  }
}

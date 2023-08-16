import Foundation
import Factory

extension Container {
  
  public var authorizationManager: Factory<AuthorizationManagerProtocol> {
    self { AuthorizationManager() }.singleton
  }
  
}

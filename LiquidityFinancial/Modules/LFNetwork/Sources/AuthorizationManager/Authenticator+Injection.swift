import Foundation
import Factory

extension Container {
  
  public var authenticator: Factory<DefaultAuthenticator> {
    self {
      DefaultAuthenticator()
    }
    .singleton
  }
}

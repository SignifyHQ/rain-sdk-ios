import Foundation
import Factory

extension Container {
  public var userDataManager: Factory<UserDataManagerProtocol> {
    self { UserDataManager() }.singleton
  }
}

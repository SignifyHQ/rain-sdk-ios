import Foundation
import LFUtilities

public protocol CustomerSupportServiceProtocol {
  var isLoginIdentifiedSuccess: Bool { get }
  func setUp(environment: NetworkEnvironment)
  func openSupportScreen()
  func loginUnidentifiedUser()
  func loginIdentifiedUser(userAttributes: UserAttributes)
  func pushEventLogin(with userAttributes: UserAttributes?)
  func pushEventLogout()
}

public extension CustomerSupportServiceProtocol {
  func setUp(environment: NetworkEnvironment) {}
  func loginUnidentifiedUser() {}
  func loginIdentifiedUser(userAttributes: UserAttributes) {}
  func pushEventLogin(with userAttributes: UserAttributes?) {}
  func pushEventLogout() {}
}

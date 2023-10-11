import Foundation

public protocol CustomerSupportServiceProtocol {
  var isLoginIdentifiedSuccess: Bool { get }
  func openSupportScreen()
  func loginUnidentifiedUser()
  func loginIdentifiedUser(userAttributes: UserAttributes)
  func pushEventLogin(with userAttributes: UserAttributes?)
  func pushEventLogout()
}

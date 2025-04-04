import Foundation

public protocol JoinWaitlistParametersEntity {
  var countryCode: String { get }
  var stateCode: String { get }
  var firstName: String { get }
  var lastName: String { get }
  var email: String { get }
}

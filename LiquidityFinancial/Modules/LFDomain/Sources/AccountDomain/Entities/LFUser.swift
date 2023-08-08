import Foundation

public protocol LFUser {
  var userID: String { get }
  var firstName: String? { get }
  var lastName: String? { get }
  var fullName: String? { get }
  var phone: String? { get }
  var email: String? { get }
  var addressEntity: AddressEntity? { get }
  var referralLink: String? { get }
}

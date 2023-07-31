import Foundation

public protocol LFUser {
  var userID: String { get }
  var addressEntity: AddressEntity? { get }
}

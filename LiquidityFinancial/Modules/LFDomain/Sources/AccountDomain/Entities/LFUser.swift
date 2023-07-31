import Foundation
import CommonDomain

public protocol LFUser {
  var userID: String { get }
  var addressEntity: AddressEntity? { get }
}

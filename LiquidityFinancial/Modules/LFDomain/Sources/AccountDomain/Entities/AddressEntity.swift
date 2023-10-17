import Foundation

// sourcery: AutoMockable
public protocol AddressEntity {
  var line1: String? { get }
  var line2: String? { get }
  var city: String? { get }
  var state: String? { get }
  var postalCode: String? { get }
  var country: String? { get }
  init(line1: String?, line2: String?, city: String?, state: String?, country: String?, postalCode: String?)
}

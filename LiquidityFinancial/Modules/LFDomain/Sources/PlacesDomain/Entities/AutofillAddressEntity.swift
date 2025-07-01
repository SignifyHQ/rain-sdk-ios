import Foundation

// sourcery: AutoMockable
public protocol AutofillAddressEntity {
  var street: String? { get }
  var city: String? { get }
  var state: String? { get }
  var postalCode: String? { get }
  var country: String? { get }
}

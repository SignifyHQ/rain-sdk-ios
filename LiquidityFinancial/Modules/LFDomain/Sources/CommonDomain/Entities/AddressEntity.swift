import Foundation

public protocol AddressEntity: Codable {
  var line1: String? { get }
  var line2: String? { get }
  var city: String? { get }
  var state: String? { get }
  var postalCode: String? { get }
  var country: String? { get }
}

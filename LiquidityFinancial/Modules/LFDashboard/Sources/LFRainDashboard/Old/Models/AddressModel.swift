import Foundation

struct AddressModel: Codable, Hashable {
  var addressType: String?
  var line1: String?
  var line2: String?
  var city: String?
  var state: String?
  var country: String?
  var postalCode: String?
}

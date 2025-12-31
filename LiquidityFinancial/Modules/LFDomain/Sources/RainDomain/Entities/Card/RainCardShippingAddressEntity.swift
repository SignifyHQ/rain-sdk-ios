public protocol RainCardShippingAddressEntity {
  var externalCardID: String? { get }
  var line1: String? { get }
  var line2: String? { get }
  var city: String? { get }
  var region: String? { get }
  var postalCode: String? { get }
  var countryCode: String? { get }
  var country: String? { get }
  var phoneNumber: String? { get }
  var method: String? { get }
  var createdAt: String? { get }
  var updatedAt: String? { get }
}

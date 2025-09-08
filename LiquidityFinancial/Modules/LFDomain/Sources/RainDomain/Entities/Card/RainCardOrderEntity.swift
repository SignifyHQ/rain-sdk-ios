public protocol RainCardOrderEntity {
  var id: String? { get }
  var userId: String { get }
  var status: String { get }
  var phoneNumber: String { get }
  var line1: String { get }
  var line2: String { get }
  var city: String { get }
  var region: String { get }
  var postalCode: String { get }
  var countryCode: String { get }
  var country: String { get }
}

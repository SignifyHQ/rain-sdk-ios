import Foundation

struct ShippingAddress {
  let line1: String
  let line2: String?
  let city: String
  let stateOrRegion: String
  let postalCode: String
  
  var description: String {
    "\(line1) \(line2 ?? ""), \(city), \(stateOrRegion) - \(postalCode)"
  }
  
  // Dummy data for UI
  static let `default` = ShippingAddress(
    line1: "123 Main Street",
    line2: nil,
    city: "Los Angeles",
    stateOrRegion: "TX",
    postalCode: "78701"
  )
}

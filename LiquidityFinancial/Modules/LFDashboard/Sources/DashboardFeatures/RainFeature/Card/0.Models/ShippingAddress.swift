import Foundation

struct ShippingAddress: Identifiable {
  var id = UUID()
  let line1: String
  let line2: String?
  let city: String
  let state: String
  let postalCode: String
  let country: String?
  
  var description: String {
    "\(line1) \(line2 ?? ""), \(city), \(state) - \(postalCode)"
  }
  
  init(
    line1: String,
    line2: String? = nil,
    city: String,
    state: String,
    postalCode: String,
    country: String? = nil
  ) {
    self.line1 = line1
    self.line2 = line2
    self.city = city
    self.state = state
    self.postalCode = postalCode
    self.country = country
  }
}

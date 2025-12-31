import Foundation
import BaseOnboarding

struct ShippingAddress: Identifiable, Hashable {
  var id = UUID()
  let line1: String
  let line2: String
  let city: String
  let state: String
  let postalCode: String
  let country: Country
  let requiresVerification: Bool
  
  var description: String {
    "\((line1 + " " + line2).trimWhitespacesAndNewlines()), \(city), \(state), \(postalCode), \(country.title)"
  }
  
  init(
    line1: String,
    line2: String = .empty,
    city: String,
    state: String,
    postalCode: String,
    country: Country,
    requiresVerification: Bool = false
  ) {
    self.line1 = line1
    self.line2 = line2
    self.city = city
    self.state = state
    self.postalCode = postalCode
    self.country = country
    self.requiresVerification = requiresVerification
  }
}

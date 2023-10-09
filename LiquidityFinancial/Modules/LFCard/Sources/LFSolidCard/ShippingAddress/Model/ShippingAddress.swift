import Foundation
import NetSpendDomain

struct ShippingAddress {
  let line1: String
  let line2: String?
  let city: String
  let state: String
  let postalCode: String
  let country: String?
  
  var description: String {
    "\(line1) \(line2 ?? ""), \(city), \(state) - \(postalCode)"
  }
}

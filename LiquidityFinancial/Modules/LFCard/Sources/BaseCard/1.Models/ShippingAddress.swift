import Foundation

public struct ShippingAddress {
  public let line1: String
  public let line2: String?
  public let city: String
  public let state: String
  public let postalCode: String
  public let country: String?
  
  public var description: String {
    "\(line1) \(line2 ?? ""), \(city), \(state) - \(postalCode)"
  }
  
  public init(
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

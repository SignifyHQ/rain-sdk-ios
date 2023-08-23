import Foundation

enum DonationType: String, Codable {
  case cardSpend = "card-spend"
  case oneTime = "one-time"

  init(from decoder: Decoder) throws {
    self = try DonationType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .cardSpend
  }
}

import Foundation

enum TransactionType: String, Codable {
  case credit
  case debit
  case reward
  case donation
  case cashback
  case unknown

  init(from decoder: Decoder) throws {
    self = try TransactionType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
  }
}

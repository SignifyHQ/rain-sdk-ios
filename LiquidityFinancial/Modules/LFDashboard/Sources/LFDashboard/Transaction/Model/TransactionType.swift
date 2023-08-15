import Foundation

enum TransactionType: String, Codable {
  case credit = "CREDIT"
  case debit = "DEBIT"
  case reward = "REWARD"
  case donation = "DONATION"
  case cashback = "CASHBACK"
  case deposit = "DEPOSIT"
  case unknown = "UNKNOW"

  init(from decoder: Decoder) throws {
    self = try TransactionType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
  }
}

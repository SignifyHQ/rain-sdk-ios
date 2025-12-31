import Foundation

enum TransferType: String, Codable {
  // account related transfer types:
  case intrabank
  case ach
  case card
  case domesticWire
  case internationalWire
  case debitCard
  case check = "physicalCheck"
  case atmFee

  // crypto related transfer types:
  case buy
  case sell
  case send
  case receive

  // default type:
  case unknown

  init(from decoder: Decoder) throws {
    self = try TransferType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
  }

  var localizedDescription: String {
    switch self {
    case .intrabank:
      return "Intra bank"
    case .ach:
      return "ACH"
    case .card:
      return "Card"
    case .domesticWire:
      return "Domestic Wire"
    case .internationalWire:
      return "International Wire"
    case .debitCard:
      return "Debit Card"
    case .check:
      return "Check"
    case .atmFee:
      return "ATM Fee"
    case .buy:
      return "Buy"
    case .sell:
      return "Sell"
    case .send:
      return "Send"
    case .receive:
      return "Receive"
    case .unknown:
      return ""
    }
  }
}

import Foundation

enum PlatformTransactionType: String, Codable {
  case purchase // card purchase
  case refund // card refund
  case cardReversal
  case atm // atm widthrawal
  case deposit // cash deposit
  case withdraw // cash withdrawal
  case fee // atm withdrawal fee, card replacement fee, etc.
  case doshReward
  case cryptoReward
  case cryptoReversalReward
  case cryptoBuy
  case cryptoBuyReversal
  case cryptoSell
  case cryptoSend
  case cryptoReceive
  case cryptoFee
  case donation
  case cashReward
  case other

  init(from decoder: Decoder) throws {
    self = try PlatformTransactionType(
      rawValue: decoder.singleValueContainer().decode(RawValue.self)
    ) ?? .other
  }
}

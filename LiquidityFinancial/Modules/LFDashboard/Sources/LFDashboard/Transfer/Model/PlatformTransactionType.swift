import Foundation
import LFStyleGuide

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

  var assetName: String {
    switch self {
    case .purchase, .atm:
      return GenImages.Images.Transactions.txCardPurchase.name
    case .refund, .cardReversal:
      return GenImages.Images.Transactions.txCardRefund.name
    case .deposit:
      return GenImages.Images.Transactions.txCashDeposit.name
    case .withdraw:
      return GenImages.Images.Transactions.txCashWithdrawal.name
    case .fee, .cryptoFee:
      return GenImages.Images.Transactions.txFees.name
    case .cryptoReward, .cryptoReversalReward, .doshReward:
      return GenImages.Images.Transactions.txCryptoReward.name
    case .cryptoBuy, .cryptoBuyReversal:
      return GenImages.Images.Transactions.txCryptoBuy.name
    case .cryptoSell:
      return GenImages.Images.Transactions.txCryptoSell.name
    case .cryptoSend:
      return GenImages.Images.Transactions.txCryptoWithdrawal.name
    case .cryptoReceive:
      return GenImages.Images.Transactions.txCryptoDeposit.name
    case .donation:
      return GenImages.Images.Transactions.txDonation.name
    case .cashReward:
      return GenImages.Images.Transactions.txCashback.name
    case .other:
      return GenImages.Images.Transactions.txOther.name
    }
  }
}

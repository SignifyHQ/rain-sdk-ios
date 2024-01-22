import Foundation
import LFStyleGuide
import LFLocalizable

public enum TransactionType: String, Codable {
  case purchase = "PURCHASE"
  case deposit = "DEPOSIT"
  case withdraw = "WITHDRAW"
  case systemFee = "SYSTEM_FEE"
  case refund = "REFUND"
  case donation = "DONATION"
  case rewardCryptoDosh = "REWARD_CRYPTOBACK_DOSH"
  case rewardCryptoBack = "REWARD_CRYPTOBACK"
  case rewardCryptoBackReverse = "REWARD_CRYPTOBACK_REVERSE"
  case rewardReferral = "REWARD_REFERRAL"
  case rewardCashBack = "REWARD_CASHBACK"
  case rewardCashBackReverse = "REWARD_CASHBACK_REVERSE"
  case cryptoBuy = "CRYPTO_BUY"
  case cryptoBuyRefund = "CRYPTO_BUY_REFUND"
  case cryptoSell = "CRYPTO_SELL"
  case cryptoWidthDraw = "CRYPTO_WITHDRAW"
  case cryptoDeposit = "CRYPTO_DEPOSIT"
  case cryptoGasDeduction = "CRYPTO_GAS_DEDUCTION"
  case unknown = "UNKNOWN"

  public init(from decoder: Decoder) throws {
    self = try TransactionType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
  }
  
  public var title: String {
    switch self {
    case .cryptoBuy:
      return LFLocalizable.TransactionDetail.Buy.title
    case .cryptoSell:
      return LFLocalizable.TransactionDetail.Sell.title
    case .cryptoWidthDraw:
      return LFLocalizable.TransactionDetail.Send.title
    case .cryptoDeposit:
      return LFLocalizable.TransactionDetail.Receive.title
    default:
      return rawValue
    }
  }
  
  public var assetName: String {
    switch self {
    case .purchase:
      return GenImages.Images.Transactions.txCardPurchase.name
    case .refund:
      return GenImages.Images.Transactions.txCardRefund.name
    case .deposit:
      return GenImages.Images.Transactions.txCashDeposit.name
    case .withdraw:
      return GenImages.Images.Transactions.txCashWithdrawal.name
    case .systemFee, .cryptoGasDeduction:
      return GenImages.Images.Transactions.txFees.name
    case .donation:
      return GenImages.Images.Transactions.txDonation.name
    case .cryptoWidthDraw:
      return GenImages.Images.Transactions.txCryptoWithdrawal.name
    case .cryptoBuy:
      return GenImages.Images.Transactions.txCryptoBuy.name
    case .cryptoSell:
      return GenImages.Images.Transactions.txCryptoSell.name
    case .cryptoDeposit:
      return GenImages.Images.Transactions.txCryptoDeposit.name
    case .cryptoBuyRefund:
      return GenImages.Images.Transactions.txCryptoDeposit.name
    case .unknown:
      return GenImages.Images.Transactions.txOther.name
    case .rewardCryptoDosh, .rewardCryptoBack, .rewardCryptoBackReverse:
      return GenImages.Images.Transactions.txCryptoReward.name
    case .rewardReferral, .rewardCashBack, .rewardCashBackReverse:
      return GenImages.Images.Transactions.txCashback.name
    }
  }
}

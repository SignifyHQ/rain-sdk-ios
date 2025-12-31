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
  case rewardWithdrawal = "REWARD_WITHDRAWAL"
  case cryptoBuy = "CRYPTO_BUY"
  case cryptoBuyRefund = "CRYPTO_BUY_REFUND"
  case cryptoSell = "CRYPTO_SELL"
  case cryptoWithdraw = "CRYPTO_WITHDRAW"
  case cryptoDeposit = "CRYPTO_DEPOSIT"
  case cryptoGasDeduction = "CRYPTO_GAS_DEDUCTION"
  case unknown = "UNKNOWN"

  public init(from decoder: Decoder) throws {
    self = try TransactionType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
  }
  
  public var title: String {
    switch self {
    case .cryptoBuy:
      return L10N.Common.TransactionDetail.Buy.title
    case .cryptoSell:
      return L10N.Common.TransactionDetail.Sell.title
    case .cryptoWithdraw:
      return L10N.Common.TransactionDetail.Send.title
    case .cryptoDeposit:
      return L10N.Common.TransactionDetail.Receive.title
    case .rewardCryptoBack:
      return L10N.Common.TransactionDetail.Reward.title
    case .rewardWithdrawal:
      return L10N.Common.TransactionDetail.RewardWithdrawal.title
    default:
      return rawValue
    }
  }
  
  public var displayTitle: String {
    switch self {
    case .withdraw, .cryptoWithdraw:
      return L10N.Common.TransactionDetails.Info.OrderType.withdrawal
    case .deposit, .cryptoDeposit:
      return L10N.Common.TransactionDetails.Info.OrderType.deposit
    case .purchase:
      return L10N.Common.TransactionDetails.Info.OrderType.purchase
    case .refund:
      return L10N.Common.TransactionDetails.Info.OrderType.refund
    default:
      return rawValue
    }
  }
  
  public var assetName: String {
    switch self {
    case .purchase:
      return GenImages.Images.txCardPurchase.name
    case .refund:
      return GenImages.Images.txCardRefund.name
    case .deposit:
      return GenImages.Images.txCashDeposit.name
    case .withdraw:
      return GenImages.Images.txCashWithdrawal.name
    case .systemFee, .cryptoGasDeduction:
      return GenImages.Images.txFees.name
    case .donation:
      return GenImages.Images.txDonation.name
    case .cryptoWithdraw, .rewardWithdrawal:
      return GenImages.Images.txCryptoWithdrawal.name
    case .cryptoBuy:
      return GenImages.Images.txCryptoBuy.name
    case .cryptoSell:
      return GenImages.Images.txCryptoSell.name
    case .cryptoDeposit:
      return GenImages.Images.txCryptoDeposit.name
    case .cryptoBuyRefund:
      return GenImages.Images.txCryptoDeposit.name
    case .unknown:
      return GenImages.Images.txOther.name
    case .rewardCryptoDosh, .rewardCryptoBack, .rewardCryptoBackReverse:
      return GenImages.Images.txCryptoReward.name
    case .rewardReferral, .rewardCashBack, .rewardCashBackReverse:
      return GenImages.Images.txCashback.name
    }
  }
  
  public var isTransferOrder: Bool {
    switch self {
    case .withdraw, .cryptoWithdraw, .deposit, .cryptoDeposit:
      return true
    default:
      return false
    }
  }
}

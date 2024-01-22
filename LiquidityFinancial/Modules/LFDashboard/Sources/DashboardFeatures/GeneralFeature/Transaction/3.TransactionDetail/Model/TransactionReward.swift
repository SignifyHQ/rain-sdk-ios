import Foundation

public struct TransactionReward {
  public var status: TransactionStatus
  public var type: RewardType
  public var amount: Double?
  public var stickerUrl: String?
  public var fundraiserName: String?
  public var charityName: String?
  public var backgroundColor: String?
  public var description: String?
}

public enum RewardType: String {
  case cashback = "CASHBACK"
  case reverseCashback = "REVERSE_CASHBACK"
  case cryptoBack = "CRYPTO_BACK"
  case reverseCryptoBack = "REVERSE_CRYPTOBACK"
  case doshCryptoBack = "DOSH_CRYPTOBACK"
  case donation = "DONATION"
  case roundUpDonation = "ROUND_UP_DONATION"
  case refferal = "REFERRAL"
  case unknow
  
  var transactionCardType: TransactionCardType {
    switch self {
    case .cashback, .reverseCashback:
      return .cashback
    case .cryptoBack, .reverseCryptoBack, .doshCryptoBack:
      return .crypto
    case .donation, .roundUpDonation:
      return .donation
    default:
      return .unknow
    }
  }
}

import Foundation
import RewardDomain

public enum APIRewardType: String, Decodable, SelectRewardTypeEntity {
  case none = "NONE"
  case cashBack = "CASHBACK"
  case reverseCashBack = "REVERSE_CASHBACK"
  case cryptoBack = "CRYPTOBACK"
  case reverseCryptoBack = "REVERSE_CRYPTOBACK"
  case doshCryptoBack = "DOSH_CRYPTOBACK"
  case donation = "DONATION"
  case roundUpDonation = "ROUND_UP_DONATION"
  case referra = "REFERRA"
  
  public var rawString: String {
    self.rawValue
  }
}

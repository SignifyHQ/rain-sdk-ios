import Foundation
import SwiftUI
import LFLocalizable
import LFStyleGuide

public enum UserRewardType: String, Codable {
  case none = "NONE"
  case cashBack = "CASHBACK"
  case reverseCashBack = "REVERSE_CASHBACK"
  case cryptoBack = "CRYPTOBACK"
  case reverseCryptoBack = "REVERSE_CRYPTOBACK"
  case doshCryptoBack = "DOSH_CRYPTOBACK"
  case donation = "DONATION"
  case roundUpDonation = "ROUND_UP_DONATION"
  case referra = "REFERRA"
}

public extension UserRewardType {
  var image: Image? {
    switch self {
    case .cashBack:
      return GenImages.CommonImages.rewardsCashback.swiftUIImage
    case .donation:
      return GenImages.CommonImages.rewardsDonation.swiftUIImage
    default:
      return nil
    }
  }
  
  var title: String? {
    switch self {
    case .cashBack:
      return L10N.Common.UserRewardType.Cashback.title
    case .donation:
      return L10N.Common.UserRewardType.Donation.title
    default:
      return nil
    }
  }
  
  func subtitle(param: Float) -> String? {
    switch self {
    case .cashBack:
      return L10N.Common.UserRewardType.Cashback.subtitle(param)
    case .donation:
      return L10N.Common.UserRewardType.Donation.subtitle(param)
    default:
      return nil
    }
  }
}

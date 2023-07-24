import Foundation
import LFLocalizable
import LFStyleGuide
import SwiftUI

enum UserRewardType: String, Codable {
  case cashback
  case donation
  case crypto = "cryptoback"
  case unspecified = ""

  init(from decoder: Decoder) throws {
    self = try UserRewardType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unspecified
  }
}

extension UserRewardType {
  var image: Image? {
    switch self {
    case .cashback:
      return GenImages.CommonImages.rewardsCashback.swiftUIImage
    case .donation:
      return GenImages.CommonImages.rewardsDonation.swiftUIImage
    case .crypto, .unspecified:
      return nil
    }
  }
}

import Foundation
import SwiftUI
import LFLocalizable

enum UserRewardType: String, Codable {
  case cashback
  case donation
  case crypto = "cryptoback"
  case unspecified = ""

  init(from decoder: Decoder) throws {
    self = try UserRewardType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unspecified
  }
}

  // MARK: - UI Helpers

extension UserRewardType {
  var image: Image {
    switch self {
    case .cashback:
      return ModuleImages.icRewardsCashback.swiftUIImage
    case .donation:
      return ModuleImages.icRewardsDonation.swiftUIImage
    case .crypto, .unspecified:
      return Image("")
    }
  }

  var title: String? {
    switch self {
    case .cashback:
      return LFLocalizable.UserRewardType.Cashback.title
    case .donation:
      return LFLocalizable.UserRewardType.Donation.title
    case .crypto, .unspecified:
      return nil
    }
  }

  var subtitle: String? {
    switch self {
    case .cashback:
      return LFLocalizable.UserRewardType.Cashback.subtitle("0.75%")
    case .donation:
      return LFLocalizable.UserRewardType.Donation.subtitle("0.75%")
    case .crypto, .unspecified:
      return nil
    }
  }
}

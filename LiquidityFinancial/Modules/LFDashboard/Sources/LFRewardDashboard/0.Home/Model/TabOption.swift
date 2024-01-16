import SwiftUI
import LFStyleGuide
import LFLocalizable

public enum TabOption: Int, CaseIterable, Hashable {
  case cash
  case donation
  case rewards
  case noneReward
  case causes
  case account
  
  var title: String {
    switch self {
    case .cash:
      return LFLocalizable.Home.CashTab.title
    case .rewards:
      return LFLocalizable.Home.RewardsTab.title
    case .donation:
      return LFLocalizable.Home.DonationTab.title
    case .causes:
      return LFLocalizable.Home.CauseTab.title
    case .account:
      return LFLocalizable.Home.AccountTab.title
    case .noneReward:
      return LFLocalizable.Home.RewardsTab.title
    }
  }
  
  var imageAsset: Image {
    switch self {
    case .cash:
      return ModuleImages.icHomeCash.swiftUIImage
    case .rewards:
      return ModuleImages.icHomeRewards.swiftUIImage
    case .donation:
      return ModuleImages.icHomeDonation.swiftUIImage
    case .causes:
      return ModuleImages.icHomeCause.swiftUIImage
    case .account:
      return ModuleImages.icHomeAccount.swiftUIImage
    case .noneReward:
      return ModuleImages.icHomeRewards.swiftUIImage
    }
  }
}

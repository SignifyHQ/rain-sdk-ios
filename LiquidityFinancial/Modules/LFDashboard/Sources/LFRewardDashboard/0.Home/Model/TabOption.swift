import SwiftUI
import LFStyleGuide
import LFLocalizable

public enum TabOption: Int, CaseIterable, Hashable {
  case cards
  case cash
  case donation
  case rewards
  case noneReward
  case causes
  case account
  case cashAsset
  
  var title: String {
    switch self {
    case .cards:
      return L10N.Common.Home.CardsTab.title
    case .cash:
      return L10N.Custom.Home.CashTab.title
    case .rewards:
      return L10N.Common.Home.RewardsTab.title
    case .donation:
      return L10N.Common.Home.DonationTab.title
    case .causes:
      return L10N.Common.Home.CauseTab.title
    case .account:
      return L10N.Common.Home.AccountTab.title
    case .noneReward:
      return L10N.Common.Home.RewardsTab.title
    case .cashAsset:
      return L10N.Custom.Home.CashTab.title
    }
  }
  
  var imageAsset: Image {
    switch self {
    case .cards:
      return GenImages.CommonImages.icHomeCards.swiftUIImage
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
    case .cashAsset:
      return ModuleImages.icHomeCash.swiftUIImage
    }
  }
}

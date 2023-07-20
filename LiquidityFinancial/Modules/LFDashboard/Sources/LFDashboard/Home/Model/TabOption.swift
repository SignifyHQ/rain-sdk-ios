import SwiftUI
import LFStyleGuide
import LFLocalizable

public enum TabOption: String {
  case cash
  case rewards
  case assets
  case account
  
  var title: String {
    switch self {
      case .cash:
        return LFLocalizable.Home.CashTab.title
      case .rewards:
        return LFLocalizable.Home.RewardsTab.title
      case .assets:
        return LFLocalizable.Home.AssetsTab.title
      case .account:
        return LFLocalizable.Home.AccountTab.title
    }
  }
  
  var imageAsset: ImageAsset {
    switch self {
      case .cash:
        return GenImages.CommonImages.icCash
      case .rewards:
        return GenImages.CommonImages.icRewards
      case .assets:
        return GenImages.CommonImages.icAssets
      case .account:
        return GenImages.CommonImages.icAccount
    }
  }
}

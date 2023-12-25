import SwiftUI
import LFStyleGuide
import LFLocalizable

public enum TabOption: String, CaseIterable {
  case cash
  case assets
  case rewards
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
  
  var imageAsset: Image {
    switch self {
    case .cash:
      return GenImages.CommonImages.icCash.swiftUIImage
    case .rewards:
      return GenImages.CommonImages.icRewards.swiftUIImage
    case .assets:
      return GenImages.CommonImages.icAssets.swiftUIImage
    case .account:
      return GenImages.CommonImages.icAccount.swiftUIImage
    }
  }
}

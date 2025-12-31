import SwiftUI
import LFStyleGuide
import LFLocalizable

public enum TabOption: String, CaseIterable {
  case cash
  case assets
  //case rewards
  case account
  
  var title: String {
    switch self {
    case .cash:
      return L10N.Custom.Home.CashTab.title
//    case .rewards:
//      return L10N.Common.Home.RewardsTab.title
    case .assets:
      return L10N.Common.Home.AssetsTab.title
    case .account:
      return L10N.Common.Home.AccountTab.title
    }
  }
  
  var imageAsset: Image {
    switch self {
    case .cash:
      return GenImages.CommonImages.icHomeCards.swiftUIImage
//    case .rewards:
//      return GenImages.CommonImages.icRewards.swiftUIImage
    case .assets:
      return GenImages.CommonImages.icAssets.swiftUIImage
    case .account:
      return GenImages.CommonImages.icAccount.swiftUIImage
    }
  }
}

import SwiftUI
import LFStyleGuide
import LFLocalizable

public enum TabItem: String, CaseIterable {
  case cash
  case assets
  case account
  
  var title: String {
    switch self {
    case .cash:
      return L10N.Common.TabBar.Tab.Card.title
    case .assets:
      return L10N.Common.TabBar.Tab.Assets.title
    case .account:
      return L10N.Common.TabBar.Tab.Account.title
    }
  }
  
  var imageAsset: Image {
    switch self {
    case .cash:
      return GenImages.Images.icoCard.swiftUIImage
    case .assets:
      return GenImages.Images.icoAsset.swiftUIImage
    case .account:
      return GenImages.Images.icoAccount.swiftUIImage
    }
  }
  
  var selectedImageAsset: Image {
    switch self {
    case .cash:
      return GenImages.Images.icoSelectedCard.swiftUIImage
    case .assets:
      return GenImages.Images.icoSelectedAsset.swiftUIImage
    case .account:
      return GenImages.Images.icoSelectedAccount.swiftUIImage
    }
  }
}

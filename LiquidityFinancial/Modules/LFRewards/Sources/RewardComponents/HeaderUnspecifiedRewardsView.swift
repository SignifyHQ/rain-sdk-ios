import SwiftUI
import LFStyleGuide
import LFUtilities

public struct HeaderUnspecifiedRewardsView: View {
  
  var bgUnspecifiedRewardImage: Image? {
    switch LFUtilities.target {
    case .CauseCard: return ModuleImages.causeBgUnspecifiedRewards.swiftUIImage
    case .PrideCard: return ModuleImages.prideBgUnspecifiedRewards.swiftUIImage
    case .PawsCard: return ModuleImages.pawsBgUnspecifiedRewards.swiftUIImage
    default: return nil
    }
  }
  
  public init() {}
  
  public var body: some View {
    if let image = bgUnspecifiedRewardImage {
      image
        .resizable()
        .aspectRatio(contentMode: .fit)
        .layoutPriority(1)
    } else {
      EmptyView()
    }
  }
}

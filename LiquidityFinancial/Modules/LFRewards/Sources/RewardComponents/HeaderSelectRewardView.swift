import SwiftUI
import LFStyleGuide
import LFUtilities

public struct HeaderSelectRewardView: View {
  
  var bgHeaderSelectRewardImage: Image? {
    switch LFUtilities.target {
    case .CauseCard: return ModuleImages.causeBgHeaderSelectReward.swiftUIImage
    case .PrideCard: return ModuleImages.prideBgHeaderSelectReward.swiftUIImage
    case .PawsCard: return ModuleImages.pawsBgHeaderSelectReward.swiftUIImage
    default: return nil
    }
  }
  
  public init() {}
  
  public var body: some View {
    if let image = bgHeaderSelectRewardImage {
      image
        .resizable()
        .frame(width: 375, height: 290)
    } else {
      EmptyView()
    }
  }
}

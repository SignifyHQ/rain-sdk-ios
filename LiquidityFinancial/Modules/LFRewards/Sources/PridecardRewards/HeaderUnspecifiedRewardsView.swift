import SwiftUI
import LFStyleGuide
import LFUtilities

public struct HeaderUnspecifiedRewardsView: View {
  
  public init() {}
  
  public var body: some View {
    ModuleImages.bgUnspecifiedRewards.swiftUIImage
      .resizable()
      .aspectRatio(contentMode: .fit)
      .layoutPriority(1)
  }
}

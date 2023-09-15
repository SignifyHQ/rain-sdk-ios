import SwiftUI
import LFStyleGuide
import LFUtilities

public struct HeaderSelectRewardView: View {
  
  public init() {}
  
  public var body: some View {
    ModuleImages.bgHeaderSelectReward.swiftUIImage
      .resizable()
      .frame(width: 375, height: 290)
  }
}

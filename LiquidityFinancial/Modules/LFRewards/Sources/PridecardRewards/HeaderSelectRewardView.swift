import SwiftUI
import LFStyleGuide
import LFUtilities

public struct HeaderSelectRewardView: View {
  
  public init() {}
  
  public var body: some View {
    ModuleImages.bgUnspecifiedRewards.swiftUIImage
      .resizable()
      .frame(width: 315, height: 177)
  }
}

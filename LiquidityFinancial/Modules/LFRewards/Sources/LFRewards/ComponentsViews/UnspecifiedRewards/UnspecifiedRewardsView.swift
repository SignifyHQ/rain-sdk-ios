import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import PridcardRewards

public struct UnspecifiedRewardsView: View {
  @State private var showEditRewards = false
  
  var destination: AnyView
  public init(destination: AnyView) {
    self.destination = destination
  }
  
  public var body: some View {
    content
      .padding(.horizontal, 30)
      .background(Colors.background.swiftUIColor)
      .navigationLink(isActive: $showEditRewards) {
        destination
      }
  }
  
  private var content: some View {
    VStack {
      ZStack(alignment: .top) {
        VStack(spacing: 0) {
          Spacer()
            .frame(height: 72)
          VStack(spacing: 0) {
            Spacer()
              .frame(height: 105)
            info
          }
          .background(Colors.secondaryBackground.swiftUIColor)
          .cornerRadius(10)
          
          EmptyListView(text: LFLocalizable.Rewards.noRewards)
            .padding(.top, 100)
        }

        bgHeaderView
      }
      Spacer()
    }
  }
  
  private var bgHeaderView: some View {
    Group {
      switch LFUtilities.target {
      case .PrideCard:
        HeaderUnspecifiedRewardsView()
      case .CauseCard:
        ModuleImages.bgUnspecifiedRewards.swiftUIImage
          .resizable()
          .frame(width: 315, height: 177)
      default: EmptyView()
      }
    }
  }
  
  private var info: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(LFLocalizable.UnspecifiedRewards.title.uppercased())
        .font(Fonts.regular.swiftUIFont(size: 18))
        .foregroundColor(Colors.label.swiftUIColor)
      
      VStack(alignment: .leading, spacing: 12) {
        row(item: .cashBack)
        row(item: .donation)
      }
      FullSizeButton(title: LFLocalizable.UnspecifiedRewards.cta, isDisable: false) {
        showEditRewards = true
      }
    }
    .padding(16)
  }
  
  private func row(item: UserRewardType) -> some View {
    HStack(spacing: 8) {
      item.image
      if let title = item.title {
        Text(title)
          .font(Fonts.regular.swiftUIFont(size: 16))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }
      Spacer()
    }
  }
}

import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import RewardComponents

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
}

// MARK: - Private View Components
private extension UnspecifiedRewardsView {
  var content: some View {
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
          
          HStack(alignment: .bottom) {
            Text(L10N.Common.Cashback.latest)
            Spacer()
          }
          .font(Fonts.regular.swiftUIFont(size: 12))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          .padding(.top, 16)
          
          EmptyListView(text: L10N.Common.Rewards.noRewards)
            .padding(.top, 100)
        }

        bgHeaderView
      }
      Spacer()
    }
  }
  
  var bgHeaderView: some View {
    Group {
      HeaderUnspecifiedRewardsView()
    }
  }
  
  var info: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(L10N.Common.UnspecifiedRewards.title.uppercased())
        .font(Fonts.regular.swiftUIFont(size: 18))
        .foregroundColor(Colors.label.swiftUIColor)
      
      VStack(alignment: .leading, spacing: 12) {
        row(item: .cashBack)
        row(item: .donation)
      }
      FullSizeButton(title: L10N.Common.UnspecifiedRewards.cta, isDisable: false) {
        showEditRewards = true
      }
    }
    .padding(16)
  }
  
  func row(item: UserRewardType) -> some View {
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

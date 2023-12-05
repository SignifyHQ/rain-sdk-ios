import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import PridecardRewards
import Factory

public enum RewardWhereStart {
  case onboarding
  case dashboard
}

public struct SelectRewardsView: View {
  @StateObject private var viewModel = SelectRewardsViewModel()
  @Injected(\.rewardNavigation) var rewardNavigation
  @State private var showPopup = false

  let whereStart: RewardWhereStart
  public init(whereStart: RewardWhereStart = .onboarding) {
    self.whereStart = whereStart
  }
  
  public var body: some View {
    content
      .background(ModuleColors.background.swiftUIColor)
      .popup(isPresented: $showPopup) {
        alert
      }
      .navigationBarHidden(true)
      .popup(item: $viewModel.showError, style: .toast) { message in
        ToastView(toastMessage: message)
      }
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case .causeFilter(let causes):
          SelectCauseCategoriesView(viewModel: SelectCauseCategoriesViewModel(causes: causes), whereStart: whereStart)
        case let .selectFundraiser(cause, fundraisers):
          SelectFundraiserView(
            viewModel: SelectFundraiserViewModel(
              causeModel: cause,
              fundraisers: fundraisers,
              showSkipButton: false),
            whereStart: whereStart
          )
        }
      }
  }
}

 // MARK: - Private View Components
private extension SelectRewardsView {
  var content: some View {
    ScrollView {
      VStack(spacing: 28) {
        asset
        VStack(alignment: .leading, spacing: 28) {
          GenImages.CommonImages.dash.swiftUIImage
            .foregroundColor(ModuleColors.label.swiftUIColor)
            .padding(.bottom, 4)
          titles
          options
          bottomView
        }
        .padding(.horizontal, 30)
      }
    }
  }
  
  var asset: some View {
    Group {
      switch LFUtilities.target {
      case .CauseCard:
        ModuleImages.bgHeaderSelectReward.swiftUIImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .layoutPriority(1)
      case .PrideCard:
        HeaderSelectRewardView()
      default:
        EmptyView()
      }
    }
  }
  
  var titles: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(LFLocalizable.SelectRewards.title.uppercased())
        .font(Fonts.regular.swiftUIFont(size: 18))
        .foregroundColor(ModuleColors.label.swiftUIColor)
      Text(LFLocalizable.SelectRewards.subtitle)
        .font(Fonts.regular.swiftUIFont(size: 12))
        .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.75))
    }
    .fixedSize(horizontal: false, vertical: true)
  }
  
  var options: some View {
    func option(_ item: SelectRewardsViewModel.Option) -> some View {
      UserRewardRowView(type: .short, reward: item.userRewardType, selection: viewModel.selection(item))
        .onTapGesture {
          viewModel.optionSelected(item)
        }
    }
    
    return VStack(spacing: 10) {
      option(.cashback)
      option(.donation)
    }
  }
  
  var bottomView: some View {
    VStack(spacing: 20) {
      cashbackDonationDisclosure
      FullSizeButton(title: LFLocalizable.SelectRewards.continue, isDisable: !viewModel.isContinueEnabled, isLoading: $viewModel.isLoading) {
        viewModel.continueTapped()
      }
    }
    .padding(.bottom, 20)
  }
  
  var cashbackDonationDisclosure: some View {
    Group {
      Text("\(LFLocalizable.DonationsDisclosure.second) ")
      +
      Text(LFLocalizable.DonationsDisclosure.text("100%"))
      +
      Text(GenImages.CommonImages.info.swiftUIImage)
    }
    .font(Fonts.regular.swiftUIFont(size: 12))
    .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.75))
    .lineSpacing(2)
    .multilineTextAlignment(.center)
    .padding(.horizontal, 22)
    .onTapGesture {
      showPopup = true
    }
  }
  
  var alert: some View {
    PopupAlert {
      VStack(spacing: 16) {
        GenImages.Images.icLogo.swiftUIImage
          .resizable()
          .frame(width: 80, height: 80)
        
        Text(LFLocalizable.DonationsDisclosure.Alert.title)
          .font(Fonts.regular.swiftUIFont(size: 18))
          .foregroundColor(ModuleColors.label.swiftUIColor)
          .padding(.top, 8)
        
        VStack(spacing: 0) {
          ShoppingGivesAlert(type: .taxDeductions)
            .frame(height: 156)
          Text(LFLocalizable.DonationsDisclosure.Alert.poweredBy)
        }
        .font(Fonts.regular.swiftUIFont(size: 16))
        .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.75))
        .lineSpacing(1.33)
        .multilineTextAlignment(.center)
        FullSizeButton(title: LFLocalizable.Button.Ok.title, isDisable: false, type: .primary) {
          showPopup = false
        }
      }
    }
  }
}

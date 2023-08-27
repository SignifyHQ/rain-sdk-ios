import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import PridcardRewards

public enum RewardWhereStart {
  case onboarding
  case dashboard
}

public struct SelectRewardsView: View {
  @StateObject private var viewModel = SelectRewardsViewModel()
  
  let destinationView: AnyView
  let whereStart: RewardWhereStart
  public init(destination: AnyView, whereStart: RewardWhereStart = .onboarding) {
    self.destinationView = destination
    self.whereStart = whereStart
  }
  
  public var body: some View {
    content
      .background(ModuleColors.background.swiftUIColor)
      .navigationBarHidden(true)
      .popup(isPresented: $viewModel.showError, style: .toast) {
        ToastView(toastMessage: LFLocalizable.genericErrorMessage)
      }
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case .causeFilter(let causes):
          SelectCauseCategoriesView(viewModel: SelectCauseCategoriesViewModel(causes: causes), destination: destinationView, whereStart: whereStart)
        case .agreement:
          destinationView
        }
      }
  }
  
  private var content: some View {
    VStack {
      asset
      
      VStack(alignment: .leading, spacing: 0) {
        GenImages.CommonImages.dash.swiftUIImage
          .foregroundColor(ModuleColors.label.swiftUIColor)
        
        titles
          .padding(.top, 32)
        
        options
          .padding(.top, 16)
        
        Spacer(minLength: 12)
        
        DonationsDisclosureView()
          .padding(.bottom, 12)
        
        continueButton
      }
      .padding(.horizontal, 30)
      .padding(.bottom, 10)
    }
  }
  
  private var asset: some View {
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
  
  private var titles: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(LFLocalizable.SelectRewards.title.uppercased())
        .font(Fonts.regular.swiftUIFont(size: 18))
        .foregroundColor(ModuleColors.label.swiftUIColor)
      Text(LFLocalizable.SelectRewards.subtitle(LFUtility.appName))
        .font(Fonts.regular.swiftUIFont(size: 12))
        .foregroundColor(ModuleColors.label.swiftUIColor.opacity(0.75))
    }
    .fixedSize(horizontal: false, vertical: true)
  }
  
  private var options: some View {
    func option(_ item: SelectRewardsViewModel.Option) -> some View {
      UserRewardRowView(type: .full, reward: item.userRewardType, selection: viewModel.selection(item))
        .onTapGesture {
          viewModel.optionSelected(item)
        }
    }
    
    return VStack(spacing: 10) {
      option(.cashback)
      option(.donation)
    }
  }
  
  private var continueButton: some View {
    FullSizeButton(title: LFLocalizable.SelectRewards.continue, isDisable: !viewModel.isContinueEnabled, isLoading: $viewModel.isLoading) {
      viewModel.continueTapped()
    }
  }
}

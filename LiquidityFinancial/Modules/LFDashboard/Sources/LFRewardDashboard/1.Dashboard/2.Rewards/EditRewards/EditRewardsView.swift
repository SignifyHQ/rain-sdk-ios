import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFRewards
import LFTransaction
import BaseDashboard

struct EditRewardsView: View {
  @StateObject private var viewModel: EditRewardsViewModel

  init(viewModel: EditRewardsViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }
  
  var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(LFLocalizable.EditRewards.navigationTitle)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.label.swiftUIColor)
        }
      }
      .popup(isPresented: $viewModel.showError, style: .toast) {
        ToastView(toastMessage: LFLocalizable.genericErrorMessage)
      }
      .disabled(viewModel.isLoading)
      .onReceive(NotificationCenter.default.publisher(for: .selectedFundraisersSuccess)) { _ in
        viewModel.handleSelectedFundraisersSuccess()
      }
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case .currentRewards:
          CurrentRewardView()
        case let .selectFundraiser(causes):
          SelectCauseCategoriesView(
            viewModel: SelectCauseCategoriesViewModel(causes: causes),
            whereStart: .dashboard
          ) { //handle on pop to root view
            viewModel.handlePopToRootView()
          }
        }
      }
  }
}

// MARK: - View Components
private extension EditRewardsView {
  var content: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(LFLocalizable.EditRewards.title)
        .font(Fonts.regular.swiftUIFont(size: 16))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .padding(.bottom, 2)
      ForEach(viewModel.rowModel, id: \.id) { item in
        UserRewardRowView(
          type: .short,
          reward: item.rewardSelecting,
          selection: viewModel.selection(item)
        )
        .onTapGesture {
          viewModel.onSelectedReward(item)
        }
      }
      Spacer()
      cashbackDonationDisclosure
      buttonsView
    }
    .padding([.top, .horizontal], 30)
  }
  
  var buttonsView: some View {
    VStack(spacing: 16) {
      ArrowButton(
        image: GenImages.CommonImages.icRewards.swiftUIImage,
        title: LFLocalizable.ChangeRewardView.currentRewards,
        value: nil,
        fontSize: Constants.FontSize.medium.value
      ) {
        viewModel.onClickedCurrentRewardsButton()
      }
      FullSizeButton(
        title: LFLocalizable.Button.Save.title,
        isDisable: viewModel.isDisableButton,
        isLoading: $viewModel.isLoading
      ) {
        viewModel.apiSelecteRewardType()
      }
    }
    .padding(.bottom, 24)
  }
  
  private var cashbackDonationDisclosure: some View {
    Text(LFLocalizable.DonationsDisclosure.second)
      .frame(maxWidth: .infinity)
      .font(Fonts.regular.swiftUIFont(size: 12))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      .multilineTextAlignment(.center)
      .padding(.bottom, 12)
      .padding(.horizontal, 24)
  }

}

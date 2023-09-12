import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFRewards

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
            .font(Fonts.regular.swiftUIFont(size: 16))
            .foregroundColor(Colors.label.swiftUIColor)
        }
      }
      .popup(isPresented: $viewModel.showError, style: .toast) {
        ToastView(toastMessage: LFLocalizable.genericErrorMessage)
      }
      .disabled(viewModel.isLoading)
      .onDisappear {
        viewModel.onDisappear()
      }
      .onReceive(NotificationCenter.default.publisher(for: .selectedFundraisersSuccess)) { _ in
        viewModel.handleSelectedFundraisersSuccess()
      }
      .navigationLink(item: $viewModel.navigation) { navigation in
        switch navigation {
        case let .selectFundraiser(causes):
          SelectCauseCategoriesView(
            viewModel: SelectCauseCategoriesViewModel(causes: causes),
            destination: AnyView(EmptyView()),
            whereStart: .dashboard) { //handle on pop to root view
              viewModel.handlePopToRootView()
            }
        }
      }
  }
  
  private var content: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(LFLocalizable.EditRewards.title)
        .font(Fonts.regular.swiftUIFont(size: 16))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .padding(.bottom, 2)
      
      ForEach(viewModel.rowModel, id: \.id) { item in
        UserRewardRowView(type: .short, reward: item.rewardSelecting, selection: viewModel.selection(item))
          .onTapGesture {
            viewModel.optionTapped(item)
          }
      }
      
      Spacer()
    }
    .padding(30)
  }
}

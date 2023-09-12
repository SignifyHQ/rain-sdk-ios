import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import BaseDashboard
import LFCard
import LFRewards

struct DashboardView: View {
  @StateObject private var viewModel: DashboardViewModel
  private var dataStorages: DashboardRepository

  init(dataStorages: DashboardRepository, option: TabOption, tabRedirection: @escaping ((TabOption) -> Void)) {
    self.dataStorages = dataStorages
    _viewModel = .init(
      wrappedValue: DashboardViewModel(option: option, tabRedirection: tabRedirection)
    )
  }
  
  var body: some View {
    Group {
      switch viewModel.option {
      case .cash:
        CashView(listCardViewModel: ListCardsViewModel(cardData: dataStorages.$cardData)) {
          viewModel.handleGuestUser()
        }
      case .rewards:
        RewardsView(viewModel: .init())
      case .noneReward:
        UnspecifiedRewardsView(destination: AnyView(EditRewardsView(viewModel: EditRewardsViewModel())))
      case .donation:
        let viewModel = DonationsViewModel(tabRedirection: { tabOption in
          log.debug(tabOption)
        })
        DonationsView(viewModel: viewModel)
      case .causes:
        let viewModel = CausesViewModel(tabRedirection: { tabOption in
          log.debug(tabOption)
        })
        CausesView(viewModel: viewModel)
      case .account:
        AccountsView()
      }
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .onAppear {
      viewModel.appearOperations()
    }
  }
}

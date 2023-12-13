import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import BaseDashboard
import LFSolidCard
import LFRewards
import Factory

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
        CashView(
          listCardViewModel: SolidListCardsViewModel(
            coordinator: Container().baseCardDestinationObservable.callAsFunction()
          )
        ) {
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
        switch LFUtilities.target {
        case .CauseCard: CausesView(viewModel: CausesViewModel())
        case .PrideCard: PrideCardCauseView(viewModel: PrideCardCauseViewModel())
        default: CausesView(viewModel: CausesViewModel())
        }
      case .account:
        AccountsView(viewModel: AccountViewModel(achInformationData: dataStorages.$achInformationData))
      }
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
  }
}

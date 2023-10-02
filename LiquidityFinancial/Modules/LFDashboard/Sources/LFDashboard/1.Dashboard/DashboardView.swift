import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFBank
import BaseDashboard
import LFCard
import Factory

struct DashboardView: View {
  
  @Injected(\.dashboardRepository) var dashboardRepository
  
  let option: TabOption
  
  init(option: TabOption) {
    self.option = option
  }
  
  var body: some View {
    Group {
      switch option {
      case .cash:
        CashView(
          viewModel:
            CashViewModel(
              accounts: (
                accountsFiat: dashboardRepository.$fiatAccounts,
                isLoading: dashboardRepository.$isLoading
              ),
              linkedAccount: dashboardRepository.$linkedAccount
            ),
          listCardViewModel: ListCardsViewModel(cardData: dashboardRepository.$cardData)
        ) { // handle refresh call back
          dashboardRepository.refreshCash()
        }
      case .rewards:
        RewardTabView(viewModel: RewardTabViewModel())
      case .assets:
        AssetsView(viewModel: AssetsViewModel())
      case .account:
        AccountsView(viewModel: AccountViewModel(achInformationData: dashboardRepository.$achInformationData, accountsCrypto: dashboardRepository.$cryptoAccounts))
      }
    }
  }
}

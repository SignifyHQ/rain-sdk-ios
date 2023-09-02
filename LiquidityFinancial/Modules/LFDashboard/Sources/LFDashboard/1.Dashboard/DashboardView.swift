import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFBank
import BaseDashboard
import LFCard

struct DashboardView: View {
  
  private var dataStorages: DashboardRepository
  
  let option: TabOption
  
  init(dataStorages: DashboardRepository, option: TabOption) {
    self.option = option
    self.dataStorages = dataStorages
  }
  
  var body: some View {
    Group {
      switch option {
      case .cash:
        CashView(
          viewModel:
            CashViewModel(
              accounts: (
                accountsFiat: dataStorages.$fiatAccounts,
                isLoading: dataStorages.$isLoading
              ),
              linkedAccount: dataStorages.$linkedAccount
            ),
          listCardViewModel: ListCardsViewModel(cardData: dataStorages.$cardData)
        ) { // handle refresh call back
          dataStorages.refreshCash()
        }
      case .rewards:
        RewardTabView(viewModel: RewardTabViewModel(
          accounts: (accountsCrypto: dataStorages.$cryptoAccounts, isLoading: dataStorages.$isLoading)
        ))
      case .assets:
        AssetsView(viewModel: AssetsViewModel(assets: dataStorages.$allAssets, isLoading: dataStorages.$isLoading))
      case .account:
        AccountsView(viewModel: AccountViewModel(achInformationData: dataStorages.$achInformationData, accountsCrypto: dataStorages.$cryptoAccounts))
      }
    }
  }
}

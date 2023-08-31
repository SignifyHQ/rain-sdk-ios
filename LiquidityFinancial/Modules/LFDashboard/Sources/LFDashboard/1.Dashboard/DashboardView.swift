import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFBank

struct DashboardView: View {
  
  private var dataStorages: HomeRepository
  
  let option: TabOption
  
  init(dataStorages: HomeRepository, option: TabOption) {
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
            )
        ) { // handle refresh call back
          dataStorages.refreshCash()
        }
      case .rewards:
        RewardTabView(viewModel: RewardTabViewModel(
          accounts: (accountsFiat: dataStorages.$cryptoAccounts, isLoading: dataStorages.$isLoading)
        ))
      case .assets:
        AssetsView(viewModel: AssetsViewModel(assets: dataStorages.$allAssets, isLoading: dataStorages.$isLoading))
      case .account:
        AccountsView(viewModel: AccountViewModel(achInformationData: dataStorages.$achInformationData))
      }
    }
  }
}

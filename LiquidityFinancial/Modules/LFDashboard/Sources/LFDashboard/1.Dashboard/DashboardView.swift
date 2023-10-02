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
          viewModel: CashViewModel(),
          listCardViewModel: ListCardsViewModel(cardData: dashboardRepository.$cardData)
        )
      case .rewards:
        RewardTabView()
      case .assets:
        AssetsView(viewModel: AssetsViewModel())
      case .account:
        AccountsView(viewModel: AccountViewModel())
      }
    }
  }
}

import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFNetspendBank
import BaseDashboard
import LFNetSpendCard
import Factory
import BaseCard

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
        if #available(iOS 16.0, *) {
          BlockingFiatView()
            .toolbarBackground(.hidden, for: .navigationBar)
        } else {
          BlockingFiatView()
        }
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

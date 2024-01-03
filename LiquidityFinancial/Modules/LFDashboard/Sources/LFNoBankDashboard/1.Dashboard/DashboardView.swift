import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFNetspendBank
import LFNetSpendCard
import Factory
import BaseCard

struct DashboardView: View {
  
  let dashboardRepository: DashboardRepository
  let option: TabOption
  
  init(option: TabOption, dashboardRepo: DashboardRepository) {
    self.dashboardRepository = dashboardRepo
    self.option = option
  }
  
  var body: some View {
    Group {
      switch option {
      case .cash:
        BlockingFiatView()
      case .rewards:
        RewardTabView(dashboardRepo: dashboardRepository)
      case .assets:
        AssetsView(dashboardRepo: dashboardRepository)
      case .account:
        AccountsView(dashboardRepo: dashboardRepository)
      }
    }
  }
}

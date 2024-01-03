import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFNetspendBank
import LFNetSpendCard
import Factory
import BaseCard

struct DashboardView: View {
  
  @Environment(\.scenePhase)
  var scenePhase
  
  let dashboardRepo: DashboardRepository
  let option: TabOption
  
  init(option: TabOption, dashboardRepo: DashboardRepository) {
    self.option = option
    self.dashboardRepo = dashboardRepo
  }
  
  var body: some View {
    Group {
      switch option {
      case .cash:
        CashView(
          viewModel: CashViewModel(dashboardRepository: dashboardRepo),
          listCardViewModel: NSListCardsViewModel(
            coordinator: Container().baseCardDestinationObservable.callAsFunction()
          )
        )
      case .rewards:
        RewardTabView(viewModel: RewardTabViewModel(dashboardRepo: dashboardRepo))
      case .assets:
        AssetsView(viewModel: AssetsViewModel(dashboardRepository: dashboardRepo))
      case .account:
        AccountsView(viewModel: AccountViewModel(dashboardRepository: dashboardRepo))
      }
    }
    .onChange(of: scenePhase, perform: { newValue in
      if newValue == .active {
        dashboardRepo.fetchNetspendLinkedSources()
      }
    })
  }
}

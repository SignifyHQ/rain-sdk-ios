import SwiftUI
import Factory
import SolidOnboarding
import LFStyleGuide
import LFUtilities
import LFRewardDashboard
import RewardData

struct AppView: View {

  @StateObject var viewModel = AppViewModel()
  @Injected(\.accountDataManager) var accountDataManager
  
  let environmentManager = EnvironmentManager()
  
  var body: some View {
    buildContent(for: viewModel.route)
  }
  
  @ViewBuilder
  private func buildContent(for route: AppCoordinator.Route) -> some View {
    Group {
      switch route {
      case.onboardingPhone:
        SolidOnboardingContentView(onRoute: .phone)
      case .onboarding:
//        EmptyView()
        SolidOnboardingContentView()
      case .dashboard:
        HomeView(viewModel: HomeViewModel(tabOptions: buildTabOption())) { route in
          viewModel.setDumpOutRoute(route)
        }
      case .dumpOut(let route):
//        EmptyView()
        SolidOnboardingContentView(onRoute: route)
      }
    }
    .embedInNavigation()
  }
  
  func buildTabOption() -> [TabOption] {
    return [TabOption.cash, TabOption.rewards, TabOption.account]
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    AppView()
  }
}

import SwiftUI
import Factory
import SolidOnboarding
import LFStyleGuide
import LFUtilities
import LFFeatureFlags
import LFRewardDashboard
import RewardData

struct AppView: View {
  
  @StateObject var viewModel = AppViewModel()
  @Injected(\.accountDataManager) var accountDataManager
  
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
        SolidOnboardingContentView()
      case .dashboard:
        HomeView(viewModel: HomeViewModel(tabOptions: buildTabOption())) { route in
          viewModel.setDumpOutRoute(route)
        }
      case .dumpOut(let route):
        SolidOnboardingContentView(onRoute: route)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden(true)
    .embedInNavigation()
  }
  
  func buildTabOption() -> [TabOption] {
    let firstTab: TabOption = LFFeatureFlagContainer.isFirstPhaseVirtualCardFeatureFlagEnabled ? .cards : .cash
    return [firstTab, TabOption.rewards, TabOption.account]
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    AppView()
  }
}

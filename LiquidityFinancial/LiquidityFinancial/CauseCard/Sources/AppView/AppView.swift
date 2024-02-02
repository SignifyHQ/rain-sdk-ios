import SwiftUI
import Factory
import SolidOnboarding
import LFStyleGuide
import LFUtilities
import LFRewardDashboard
import RewardData
import LFFeatureFlags

struct AppView: View {

  @StateObject var viewModel = AppViewModel()
  @Injected(\.accountDataManager) var accountDataManager
  @Injected(\.featureFlagManager) var featureFlagManager
  
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
    var options: [TabOption] = []
    
    if featureFlagManager.isFeatureFlagEnabled(.donationAssets) {
      options.append(.cashAsset)
    } else if featureFlagManager.isFeatureFlagEnabled(.virtualCardPhrase1) {
      options.append(.cards)
    } else {
      options.append(.cash)
    }
    
    options.append(contentsOf: [.rewards, .account])
    
    return options
  }
}

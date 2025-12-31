import SwiftUI
import Factory
import RainOnboarding
import LFStyleGuide
import LFUtilities
import LFRainDashboard

struct AppView: View {

  @StateObject var viewModel = AppViewModel()
  @Injected(\.accountDataManager) var accountDataManager
  
  var body: some View {
    buildContent(for: viewModel.route)
  }
  
  @ViewBuilder
  private func buildContent(
    for route: AppCoordinator.Route
  ) -> some View {
    Group {
      switch route {
      case.onboardingPhone:
        RainOnboardingContentView(onRoute: .phone)
      case .onboarding:
        RainOnboardingContentView()
      case .dashboard:
        MainTabBar { route in
          viewModel.setDumpOutRoute(route)
        }
      case .dumpOut(let route):
        RainOnboardingContentView(onRoute: route)
      }
    }
    .embedInNavigation()
  }
}

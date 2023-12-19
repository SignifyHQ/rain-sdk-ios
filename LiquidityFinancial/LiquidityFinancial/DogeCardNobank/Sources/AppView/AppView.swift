import SwiftUI
import Factory
import LFStyleGuide
import LFUtilities
import LFNoBankDashboard
import NoBankOnboarding

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
        NSOnboardingContentView(onRoute: .phone)
      case .onboarding:
        NSOnboardingContentView()
      case .dashboard:
        HomeView(viewModel: HomeViewModel(tabOptions: TabOption.allCases)) { route in
          viewModel.setDumpOutRoute(route)
        }
      case .dumpOut(let route):
        NSOnboardingContentView(onRoute: route)
      }
    }
    .embedInNavigation()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    AppView()
  }
}

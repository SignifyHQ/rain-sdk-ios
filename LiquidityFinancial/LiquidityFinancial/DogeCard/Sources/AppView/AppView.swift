import SwiftUI
import Factory
import LFAccountOnboarding
import LFStyleGuide
import LFUtilities
import LFDashboard

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
        OnboardingContentView(onRoute: .phone)
      case .onboarding:
        OnboardingContentView()
      case .dashboard:
        HomeView(viewModel: HomeViewModel(tabOptions: TabOption.allCases)) { route in
          viewModel.setDumpOutRoute(route)
        }
      case .dumpOut(let route):
        OnboardingContentView(onRoute: route)
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

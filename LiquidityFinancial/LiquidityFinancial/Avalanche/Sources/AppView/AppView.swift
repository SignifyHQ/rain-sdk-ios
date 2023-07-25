import SwiftUI
import Factory
import LFAccountOnboarding
import LFStyleGuide
import LFUtilities
import AvalancheAccountOnboarding
import LFDashboard

struct AppView: View {

  @StateObject var viewModel = AppViewModel()
  @Injected(\.userDataManager) var userDataManager
  
  let environmentManager = EnvironmentManager()
  
  var body: some View {
    buildContent(for: viewModel.route)
  }
  
  @ViewBuilder
  private func buildContent(for route: AppCoordinator.Route) -> some View {
    Group {
      switch route {
      case .onboarding:
        OnboardingContentView()
      case .dashboard:
        HomeView(viewModel: HomeViewModel(), tabOptions: TabOption.allCases)
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

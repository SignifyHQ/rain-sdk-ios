import SwiftUI
import Factory
import LFAccountOnboarding
import LFStyleGuide
import LFUtilities
import AvalancheAccountOnboarding

struct AppView: View {

  @StateObject var viewModel = AppViewModel()
  
  let environmentManager = EnvironmentManager()
  
  var body: some View {
    buildContent(for: viewModel.route)
  }
  
  @ViewBuilder
  private func buildContent(for route: AppCoordinator.Route) -> some View {
    Group {
      switch route {
      case .initial:
        InitialView()
      case .onboarding:
        PhoneNumberView(
          viewModel: Container.shared.phoneNumberViewModel.callAsFunction()
        )
        .environmentObject(environmentManager)
      case .welcome:
        WelcomeView()
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

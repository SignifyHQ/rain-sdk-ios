import SwiftUI
import Factory
import LFAccountOnboarding
import LFStyleGuide
import LFUtilities
import AvalancheAccountOnboarding

struct AppView: View {

  let environmentManager = EnvironmentManager()
  
  var body: some View {
    Group {
      //PhoneNumberView(viewModel: Container.shared.phoneNumberViewModel.callAsFunction())
      //  .environmentObject(environmentManager)
      PersonalInformationView(isAppView: true)
    }
    .embedInNavigation()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    AppView()
  }
}

import SwiftUI
import LFFeatureFlags

@main
struct PrideCardApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate
  
  init() {
    LFFeatureFlagContainer.registerViewFactoryPridecard()
  }
  
  @State var showFeatureFlagsHubView = false

  var body: some Scene {
    WindowGroup {
      AppView()
      #if DEBUG
        .onShake {
          hideKeyboard()
          showFeatureFlagsHubView.toggle()
        }
        .sheet(isPresented: $showFeatureFlagsHubView, content: {
          LFFeatureFlagsHubView()
            .embedInNavigation()
        })
      #endif
    }
  }
}

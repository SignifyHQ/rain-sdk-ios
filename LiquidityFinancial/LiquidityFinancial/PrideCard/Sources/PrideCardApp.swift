import SwiftUI
import LFFeatureFlags

@main
struct PrideCardApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate
  
  @State var showFeatureFlagsHubView = false
  
  init() {
    LFFeatureFlagContainer.registerViewFactoryPridecard()
  }
  
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

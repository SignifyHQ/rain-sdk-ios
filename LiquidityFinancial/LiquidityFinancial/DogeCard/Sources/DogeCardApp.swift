import SwiftUI
import LFFeatureFlags

@main
struct DogeCardApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate
  
  @State var showFeatureFlagsHubView = false
  
  init() {
    LFFeatureFlagContainer.registerViewFactoryDogecard()
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
        })
      #endif
    }
  }
}

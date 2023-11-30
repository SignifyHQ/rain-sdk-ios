import SwiftUI
import LFFeatureFlags

@main
struct CauseCardApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate
  
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
      })
    #endif
    }
  }
}

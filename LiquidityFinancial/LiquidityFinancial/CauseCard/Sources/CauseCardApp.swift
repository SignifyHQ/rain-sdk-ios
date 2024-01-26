import SwiftUI
import LFFeatureFlags

@main
struct CauseCardApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate
  
  @State var showFeatureFlagsHubView = false
  
  init() {
  }
  
  var body: some Scene {
    WindowGroup {
      AppView()
    }
  }
}

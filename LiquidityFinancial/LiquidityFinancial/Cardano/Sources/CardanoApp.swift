import SwiftUI
import LFFeatureFlags

@main
struct CardanoApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate
  
  @State var showFeatureFlagsHubView = false
  
  var body: some Scene {
    WindowGroup {
      AppView()
    }
  }
}

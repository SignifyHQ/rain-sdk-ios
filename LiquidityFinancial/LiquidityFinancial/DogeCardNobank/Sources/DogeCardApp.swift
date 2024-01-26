import SwiftUI
import LFFeatureFlags

@main
struct DogeCardApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate
  
  @State var showFeatureFlagsHubView = false
  
  var body: some Scene {
    WindowGroup {
      AppView()
    }
  }
}

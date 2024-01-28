import SwiftUI
import LFUtilities

@main
struct PrideCardApp: App {
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

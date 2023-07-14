import SwiftUI
import LFAccountOnboarding
import CardanoAccountOnboarding

@main
struct AvalancheApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate
  
  var body: some Scene {
    WindowGroup {
      AppView()
    }
  }
}

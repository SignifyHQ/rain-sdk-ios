import SwiftUI

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

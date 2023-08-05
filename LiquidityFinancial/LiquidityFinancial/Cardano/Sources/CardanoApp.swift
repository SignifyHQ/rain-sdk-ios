import SwiftUI

@main
struct CardanoApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate
  
  var body: some Scene {
    WindowGroup {
      AppView()
    }
  }
}

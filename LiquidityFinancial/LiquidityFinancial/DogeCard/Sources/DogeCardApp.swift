import SwiftUI

@main
struct DogeCardApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate
  
  var body: some Scene {
    WindowGroup {
      AppView()
    }
  }
}

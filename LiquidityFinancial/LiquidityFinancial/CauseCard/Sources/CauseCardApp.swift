import SwiftUI
import CauseCardOnboarding

@main
struct CauseCardApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self)
  var appDelegate
  
  var body: some Scene {
    WindowGroup {
      DonationsDisclosureView()
    }
  }
}

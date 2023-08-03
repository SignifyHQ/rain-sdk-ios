import Foundation
import LFStyleGuide
import DataUtilities
import LFUtilities

// swiftlint:disable force_unwrapping

extension AppDelegate {
  
  func setupConfigs() {
    setupStyleGuideConfig()
    setupDataUtilitiesConfig()
    setupLFUtilitiesConfig()
  }
  
}

private extension AppDelegate {
  var target: String {
    Bundle.main.executableURL!.lastPathComponent
  }
  
  func setupStyleGuideConfig() {
    LFStyleGuide.initial(target: target)
  }
  
  func setupDataUtilitiesConfig() {
    DataUtilities.initial(target: target)
  }
  
  func setupLFUtilitiesConfig() {
    LFUtilities.initial(target: target)
    DBCustomHTTPProtocol.ignoredHosts.append("nexus-websocket-a.intercom.io")
    DBCustomHTTPProtocol.ignoredHosts.append("ursuzkbg-ios.mobile-messenger.intercom.com")
  }
}

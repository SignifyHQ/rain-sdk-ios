import Foundation
import LFStyleGuide
import NetworkUtilities
import LFUtilities
import Factory
import AuthorizationManager

// swiftlint:disable force_unwrapping

extension AppDelegate {
  
  func setupConfigs() {
    setupStyleGuideConfig()
    setupDataUtilitiesConfig()
    setupLFUtilitiesConfig()
    authorizationManagerRefresh()
  }
  
}

private extension AppDelegate {
  var target: String {
    Bundle.main.executableURL!.lastPathComponent
  }
  
  func authorizationManagerRefresh() {
    authorizationManager.update()
  }
  
  func setupStyleGuideConfig() {
    LFStyleGuide.initial(target: target)
  }
  
  func setupDataUtilitiesConfig() {
    NetworkUtilities.initial(target: target)
  }
  
  func setupLFUtilitiesConfig() {
    LFUtilities.initial(target: target)
    DBCustomHTTPProtocol.ignoredHosts.append("nexus-websocket-a.intercom.io")
    DBCustomHTTPProtocol.ignoredHosts.append("ursuzkbg-ios.mobile-messenger.intercom.com")
  }
}

import Foundation
import LFStyleGuide
import NetworkUtilities
import LFUtilities
import Factory
import AuthorizationManager
import LFServices

// swiftlint:disable force_unwrapping

extension AppDelegate {
  
  func setupConfigs() {
    setupStyleGuideConfig()
    setupDataUtilitiesConfig()
    setupLFUtilitiesConfig()
    setupLFServiceConfig()
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
    DBCustomHTTPProtocol.ignoredHosts.append("http://nexus-websocket-a.intercom.io")
    DBCustomHTTPProtocol.ignoredHosts.append("http://api.segment.io/v1/batch")
    DBCustomHTTPProtocol.ignoredHosts.append("http://ursuzkbg-ios.mobile-messenger.intercom.com")
  }
  
  func setupLFServiceConfig() {
    LFServices.initial(config: LFServices.Configuration(baseURL: APIConstants.devHost))
  }
}

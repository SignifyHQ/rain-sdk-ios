import Foundation
import LFStyleGuide
import NetworkUtilities
import LFUtilities
import Factory
import AuthorizationManager
import Services
import LFFeatureFlags

// swiftlint:disable force_unwrapping

extension AppDelegate {
  
  func setupConfigs() {
    setupStyleGuideConfig()
    setupDataUtilitiesConfig()
    setupLFUtilitiesConfig()
    setupLFServiceConfig()
    authorizationManagerRefresh()
    setupPortal()
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
    DBCustomHTTPProtocol.ignoredHosts.append("http://api.segment.io/v1/batch")
  }
  
  func setupLFServiceConfig() {
    LFServices.initial(config: LFServices.Configuration(baseURL: APIConstants.devHost))
  }
  
  func setupPortal() {
    let clientSessionToken = UserDefaults.portalSessionToken
    guard !clientSessionToken.trimWhitespacesAndNewlines().isEmpty else {
      return
    }
    
    Task {
      do {
        try await registerPortalUsecase.execute(portalToken: clientSessionToken)
      } catch {
        log.error("An error occurred while creating the portal instance \(error)")
      }
    }
  }
}

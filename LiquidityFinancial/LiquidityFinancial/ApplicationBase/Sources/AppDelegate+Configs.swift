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
    DBCustomHTTPProtocol.ignoredHosts.append("http://nexus-websocket-a.intercom.io")
    DBCustomHTTPProtocol.ignoredHosts.append("http://api.segment.io/v1/batch")
    DBCustomHTTPProtocol.ignoredHosts.append("http://ursuzkbg-ios.mobile-messenger.intercom.com")
  }
  
  func setupLFServiceConfig() {
    LFServices.initial(config: LFServices.Configuration(baseURL: APIConstants.devHost))
  }
  
  func setupPortal() {
    let clientSessionToken = UserDefaults.portalSessionToken
    guard !clientSessionToken.trimWhitespacesAndNewlines().isEmpty else {
      return
    }
    
    // TODO: - alchemyAPIKey will be implemented later
    Task {
      do {
        _ = try await portalService.registerPortal(
          sessionToken: clientSessionToken,
          alchemyAPIKey: .empty
        )
      } catch {
        refreshPortalSessionToken()
        log.error("An error occurred while creating the portal instance \(error)")
      }
    }
  }
  
  func refreshPortalSessionToken() {
    Task {
      do {
        let token = try await refreshPortalToken.execute()
        
        authorizationManager.savePortalSessionToken(token: token.clientSessionToken)
        _ = try await portalService.registerPortal(
          sessionToken: token.clientSessionToken,
          alchemyAPIKey: .empty
        )
        
      } catch {
        log.error("An error occurred while refreshing the portal client session \(error)")
      }
    }
  }
}

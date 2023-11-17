import Foundation
import UIKit
import Services
import Factory
import AuthorizationManager
import LFUtilities
import EnvironmentService

class AppDelegate: UIResponder, UIApplicationDelegate {
  
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.environmentService) var environmentService
  
  var navigationContainer: NavigationContainer!
  
  var orientationLock = UIInterfaceOrientationMask.portrait
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    setUpAppearence()
    setupConfigs()
    setupNavigaton()
    KickoffService.kickoff(application: application, launchingOptions: options)
    UserDefaults.isFirstRun = false
    setupServices()
    return true
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    KickoffService.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    
  }
  
  func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    NotificationsReceived.shared.addNotification(userInfo)
    guard let aps = userInfo["aps"] as? [String: AnyObject] else {
      completionHandler(.failed)
      return
    }
    log.debug("got something, aka the \(aps)")
    completionHandler(.newData)
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
    return true
  }
  
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    return true
  }
  
  func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
    return true
  }
  
  func application(_: UIApplication, supportedInterfaceOrientationsFor _: UIWindow?) -> UIInterfaceOrientationMask {
    orientationLock
  }
}

extension AppDelegate {
  func setupNavigaton() {
    navigationContainer = NavigationContainer()
    navigationContainer.registerModuleNavigation()
  }
}

extension AppDelegate {
  func setupServices() {
    Container.shared.customerSupportService.resolve().setUp(environment: environmentService.networkEnvironment)
  }
}

import NetspendSdk
import UIKit
import FraudForce
import LFUtilities
import Intercom

public enum KickoffService {
  static var networkEnvironment: NetworkEnvironment {
    EnvironmentManager().networkEnvironment
  }
  
  public static func kickoff(application: UIApplication, launchingOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    kickoffNetspend()
    kichOffIntercom()
  }
  
  public static func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Set device token for push notifications.
    Intercom.setDeviceToken(deviceToken) { error in
      guard let error = error else { return }
      log.error("Error setting device token: \(error.localizedDescription)")
    }
  }
}

// MARK: Intercom
extension KickoffService {
  static func kichOffIntercom() {
      // Setup Intercom
    let apiKey = networkEnvironment == .productionTest ? Configs.Intercom.apiKeySandBox : Configs.Intercom.apiKey
    let appID = networkEnvironment == .productionTest ? Configs.Intercom.appIDSandBox : Configs.Intercom.appID
    Intercom.setApiKey(apiKey, forAppId: appID)
    Intercom.setLauncherVisible(false)
  }
}

// MARK: NetSpend
extension KickoffService {
  static func kickoffNetspend() {
    NetSpendService.kickoffNetspend(networkEnvironment: networkEnvironment)
  }
}

import NetspendSdk
import UIKit
import FraudForce
import LFUtilities
import Intercom
import Firebase
import Factory
import DatadogRUM
import DatadogTrace
import DatadogCore

public enum KickoffService {
  
  static var networkEnvironment: NetworkEnvironment {
    EnvironmentManager().networkEnvironment
  }
  
  public static func kickoff(application: UIApplication, launchingOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    kickoffFirebase()
    kickoffNetspend()
    kichOffIntercom()
    kickoffDataDog()
    kickoffPushNotifications(application: application)
  }
  
  public static func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Set device token for push notifications.
    Messaging.messaging().setAPNSToken(
      deviceToken,
      type: networkEnvironment == .productionTest ? .sandbox : .prod
    )
    Intercom.setDeviceToken(deviceToken) { error in
      guard let error = error else { return }
      log.error("Intercom Error setting device token: \(error.localizedDescription)")
    }
  }
  
  private static func kickoffAnalytics() {
    // firing here to ensure all analytics is setup.
    Container.shared.analyticsService.callAsFunction().track(event: AnalyticsEvent(name: .appLaunch))
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

// MARK: Firebase {
extension KickoffService {
  private static func kickoffFirebase() {
    FirebaseApp.configure()
  }
}

// MARK: Push notification
extension KickoffService {
  private static func kickoffPushNotifications(application: UIApplication) {
    Container.shared.pushNotificationService.resolve().setUp()
    application.registerForRemoteNotifications()
  }
}

// MARK: DataDoge
extension KickoffService {
  private static func kickoffDataDog() {
    let appID = Configs.DataDog.appID
    let clientToken = Configs.DataDog.clientToken
    let environment = networkEnvironment.rawValue
    Datadog.initialize(
      with: Datadog.Configuration(
        clientToken: clientToken, env: environment, site: .us5, service: LFUtilities.appName
      ),
      trackingConsent: .granted
    )
    
    DatadogRUM.RUM.enable(
      with: RUM.Configuration(
        applicationID: appID,
        urlSessionTracking: RUM.Configuration.URLSessionTracking(),
        trackBackgroundEvents: true
      )
    )
    log.addDestination(DataDogLogDestination())
  }
}

import NetspendSdk
import UIKit
import FraudForce
import LFUtilities
import Firebase
import Factory

public enum KickoffService {
  
  static var networkEnvironment: NetworkEnvironment {
    EnvironmentManager().networkEnvironment
  }
  
  public static func kickoff(application: UIApplication, launchingOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    kickoffFirebase()
    kickoffNetspend()
    kickoffDataDog()
    kickoffPushNotifications(application: application)
  }
  
  public static func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Set device token for push notifications.
    Messaging.messaging().setAPNSToken(
      deviceToken,
      type: networkEnvironment == .productionTest ? .sandbox : .prod
    )
  }
  
  private static func kickoffAnalytics() {
    // firing here to ensure all analytics is setup.
    Container.shared.analyticsService.callAsFunction().track(event: AnalyticsEvent(name: .appLaunch))
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
    DataDogService.kickoffDataDog(networkEnvironment: networkEnvironment)
  }
}

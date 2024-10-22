import NetspendSdk
import UIKit
import FraudForce
import LFUtilities
import Firebase
import Factory
import EnvironmentService

public enum KickoffService {
  
  static var networkEnvironment: NetworkEnvironment {
    LFServices.environmentService.networkEnvironment
  }
  
  public static func kickoff(
    application: UIApplication,
    launchingOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) {
    kickoffFirebase()
    kickoffNetspend()
    kickoffAnalytics()
    kickoffPushNotifications(application: application)
  }
  
  public static func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Container.shared.pushNotificationService.resolve().setupCloudMessaging(token: deviceToken, environment: networkEnvironment)
  }
  
  private static func kickoffAnalytics() {
    Container.shared.analyticsService.callAsFunction().track(event: AnalyticsEvent(name: .appLaunch))
    Container.shared.analyticsService.resolve().setUp(environment: networkEnvironment.rawValue)
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
  public static func kickoffFirebase() {
    if let filePath = LFServices.googleInfoFilePath,
       let options = FirebaseOptions(contentsOfFile: filePath) {
      if let app = FirebaseApp.app() {
        app.delete { success in
          if success {
            FirebaseApp.configure(options: options)
          } else {
            fatalError("Couldn't delete existing Firebase app.")
          }
        }
      } else {
        FirebaseApp.configure(options: options)
      }
      
      log.info("Successfully configured Firebase for \(networkEnvironment) from \(filePath)")
    } else {
      fatalError("Couldn't load Firebase configuration file.")
    }
  }
}

// MARK: Push notification
extension KickoffService {
  private static func kickoffPushNotifications(application: UIApplication) {
    Container.shared.pushNotificationService.resolve().setUp()
    application.registerForRemoteNotifications()
  }
}

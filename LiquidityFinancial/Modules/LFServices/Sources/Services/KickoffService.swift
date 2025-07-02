import EnvironmentService
import Factory
import Firebase
import FirebaseAppCheck
import FraudForce
import GooglePlacesSwift
import LFUtilities
import NetspendSdk
import UIKit

public enum KickoffService {
  
  static var networkEnvironment: NetworkEnvironment {
    LFServices.environmentService.networkEnvironment
  }
  
  @MainActor
  public static func kickoff(
    application: UIApplication,
    launchingOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) {
    kickoffAppCheck()
    kickoffFirebase()
    kickoffNetspend()
    kickoffAnalytics()
    kickoffPushNotifications(application: application)
    kickoffGooglePlaces()
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
  public static func kickoffAppCheck() {
    let appCheck = LFAppCheckProviderFactory()
    AppCheck.setAppCheckProviderFactory(appCheck)
  }
  
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

// MARK: Google Places
extension KickoffService {
  @MainActor
  private static func kickoffGooglePlaces() {
    let apiKey = Configs.GooglePlaces.apiKey(for: networkEnvironment)
    let kickedOffGooglePlaces = PlacesClient.provideAPIKey(apiKey)
    
    if kickedOffGooglePlaces {
      log.info("Successfully configured Google Places for \(networkEnvironment) with \(apiKey)")
    } else {
      log.error("Error configuring Google Places for \(networkEnvironment)")
    }
  }
}

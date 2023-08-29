import FirebaseMessaging
import UserNotifications
import Foundation
import Factory
import LFUtilities

extension Container {
  public var pushNotificationService: Factory<PushNotificationsService> {
    self {
      PushNotificationsService()
    }.singleton
  }
}

public class PushNotificationsService: NSObject {
  public func setUp() {
    UNUserNotificationCenter.current().delegate = self
    Messaging.messaging().delegate = self
  }
  
  public func notificationSettingStatus() async throws -> UNAuthorizationStatus {
    return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<UNAuthorizationStatus, Error>) in
      let center = UNUserNotificationCenter.current()
      center.getNotificationSettings { settings in
        continuation.resume(returning: settings.authorizationStatus)
      }
    })
  }
  
  public func requestPermission() async throws -> Bool {
    return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Bool, Error>) in
      let center = UNUserNotificationCenter.current()
      center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
        if let error = error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(returning: success)
        }
      }
    })
  }
  
  public func fcmToken() async throws -> String {
    return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
      Messaging.messaging().token { token, error in
        if let token = token {
          continuation.resume(returning: token)
        } else {
          continuation.resume(throwing: error ?? LFConfiguration.Error.invalidValue)
        }
      }
    })
  }
}

extension PushNotificationsService: UNUserNotificationCenterDelegate {
  public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    handleNotification(userInfo: response.notification.request.content.userInfo)
    completionHandler()
  }

  public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // Method called when the notification arrives with the app in foreground.
    completionHandler([.banner, .sound])
  }

  private func handleNotification(userInfo: [AnyHashable: Any]) {
    log.info("Handle notification \(userInfo)")
  }
}

// MARK: MessagingDelegate

extension PushNotificationsService: MessagingDelegate {
  public func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    log.info("notification didReceiveRegistrationToken: \(fcmToken ?? "empty")")
  }
}

import Foundation

public final class NotificationsReceived {
  public static let shared = NotificationsReceived()
  fileprivate (set) var notifications: [(date: Date, dict: [AnyHashable: Any])] = []
  public func addNotification(_ notification: [AnyHashable: Any]) {
    notifications.insert((Date(), notification), at: 0)
  }
}

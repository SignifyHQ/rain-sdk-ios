import Foundation

// sourcery: AutoMockable
public protocol NotificationTokenEntity {
  var success: Bool { get }
  init(success: Bool)
}

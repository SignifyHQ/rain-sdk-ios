import Foundation

// MARK: - AnalyticsTransportProtocol

public protocol AnalyticsTransportProtocol: AnyObject {
  func track(event: EventType)
  func set(params: [String: Any])
  func flush(force: Bool)
  func track(screen: String, appear: Bool)
}

import DatadogRUM
import DatadogCore
import Foundation
import LFUtilities

class DataDogTransport: AnalyticsTransportProtocol {
  func track(screen: String, appear: Bool) {
    // Datadog is direct support with SwiftUI so we don't need setup up here
  }
  
  func track(event: EventType) {
    RUMMonitor.shared().addAttribute(forKey: event.name, value: event.params.description)
  }
  
  func set(params: [String: Any]) {
    guard let id = params["id"] as? String else { return }
    let email = params["email"] as? String
    let username = params["phone"] as? String
    Datadog.setUserInfo(id: id, name: username.orEmpty, email: email.orEmpty)
  }
  
  func flush(force _: Bool) {}
}

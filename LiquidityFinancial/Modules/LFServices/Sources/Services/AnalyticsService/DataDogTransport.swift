import DatadogRUM
import DatadogCore
import LFUtilities
import DatadogLogs
import DatadogTrace
import DatadogCrashReporting
import EnvironmentService

class DataDogTransport: AnalyticsTransportProtocol {
  func setUp(environment: String) {
    let readRUMApplicationID = Configs.DataDog.appID
    let clientToken = Configs.DataDog.clientToken
    let serviceName = "ios-liquidity-new-\(LFUtilities.target?.rawValue.lowercased() ?? "")-\(environment)"
    let partyHosts: Set<String> = [
      LFServices.config.baseURL.deletingPrefix("https://")
    ]
    
    // Initialize Datadog SDK
    Datadog.initialize(
      with: Datadog.Configuration(
        clientToken: clientToken,
        env: environment,
        site: .us5,
        service: serviceName,
        batchSize: .medium,
        uploadFrequency: .frequent
      ),
      trackingConsent: .granted
    )
    
    // Enable Logs
    Logs.enable()
    
    // Enable Crash Reporting
    CrashReporting.enable()
    
    // Enable RUM
    RUM.enable(
      with: RUM.Configuration(
        applicationID: readRUMApplicationID,
        urlSessionTracking: .init(firstPartyHostsTracing: .trace(hosts: partyHosts, sampleRate: 50)),
        trackBackgroundEvents: true,
        telemetrySampleRate: 50
      )
    )
    
    RUMMonitor.shared().debug = false
    let success = log.addDestination(DataDogLogDestination())
    log.info(success)
  }
  
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

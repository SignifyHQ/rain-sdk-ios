import LFUtilities
import UIKit
import DatadogCore
import DatadogRUM
import DatadogLogs
import DatadogTrace
import DatadogCrashReporting
import EnvironmentService

//swiftlint:disable convenience_type
final class DataDogService {
  
  static func kickoffDataDog(networkEnvironment: NetworkEnvironment) {
    let readRUMApplicationID = Configs.DataDog.appID
    let clientToken = Configs.DataDog.clientToken
    let environment = networkEnvironment.rawValue
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
}

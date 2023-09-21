import Foundation
import Segment
import LFUtilities

class SegmentTransport: AnalyticsTransportProtocol {
  init() {
    let segmentAPIKey = LFServices.segmentKey
    let configuration = AnalyticsConfiguration(writeKey: segmentAPIKey)
    configuration.recordScreenViews = false
    configuration.trackApplicationLifecycleEvents = true
    configuration.trackPushNotifications = true
    configuration.trackDeepLinks = true
    
    Analytics.setup(with: configuration)
    
    Analytics.shared().group(LFUtility.appName, traits: [:])
  }
  
  func track(event: EventType) {
    Analytics.shared().track(event.name, properties: event.params)
  }
  
  func track(screen: String, appear: Bool) {
    guard appear else { return }
    Analytics.shared().screen(screen)
  }
  
  func set(params: [String: Any]) {
    let paramsUpdate = pushPlatformTo(params: params)
    if let userId = paramsUpdate[PropertiesName.id.rawValue] as? String {
      Analytics.shared().identify(userId, traits: paramsUpdate)
    } else {
      Analytics.shared().identify(nil, traits: paramsUpdate)
    }
  }
  
  func flush(force _: Bool) {
    Analytics.shared().flush()
  }
}

private extension SegmentTransport {
    // we need push os-name: When a user is identified in segment (IDENTIFY)
  func pushPlatformTo(params: [String: Any]) -> [String: Any] {
    var unwrapParams = params
    unwrapParams[PropertiesName.segmentOS.rawValue] = [PropertiesName.segmentName.rawValue: AnalyticsEventName.platform.rawValue]
    return unwrapParams
  }
}

//extension UserModel {
//  func encodeAnalytics() -> [String: Any] {
//    var values = dictionary ?? [:]
//    values["birthday"] = dateOfBirth?.getDate()
//    values["avatar"] = profileImage
//    values["idNumber"] = "REDACTED"
//    return values
//  }
//}

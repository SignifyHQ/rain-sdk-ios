import Foundation

public extension Bundle {
  var appName: String? {
    object(forInfoDictionaryKey: "CFBundleName") as? String
  }
  
  var appVersion: String? {
    object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
  }
  
  var buildNumber: String? {
    object(forInfoDictionaryKey: "CFBundleVersion") as? String
  }
}

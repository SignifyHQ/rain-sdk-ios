import Foundation
import LFUtilities

public struct FeatureConfigModel: Codable {
  public struct PlatformVersion: Codable {
    public let minVersionNumber: Int?
    public let minVersionString: String?
  }
  
  public struct Version: Codable {
    public let ios: PlatformVersion?
  }
  
  public let features: [String: AnyCodable]?
  public let version: Version?
  
  public var minVersionNumber: Int {
    version?.ios?.minVersionNumber ?? 0
  }
  
  public var minVersionString: String {
    version?.ios?.minVersionString ?? ""
  }
  
  public var isSendCryptoV2Enabled: Bool {
    guard let isSendCryptoV2Enabled = features?["isSendCryptoV2Enabled"] as? Bool else {
      return false
    }
    return isSendCryptoV2Enabled
  }
}

import Foundation
import LFUtilities

// sourcery: AutoMockable
public struct FeatureConfigModel: Codable {
  public struct BlockingAlert: Codable {
    public let forcedUpgrade: ForcedUpgrade?
  }
  
  public struct ForcedUpgrade: Codable {
    public let title: String
    public let titleButton: String
    public let description: String
  }
  
  public struct PlatformVersion: Codable {
    public let minVersionNumber: Int?
    public let minVersionString: String?
  }
  
  public struct Version: Codable {
    public let ios: PlatformVersion?
  }
  
  public let features: [String: AnyCodable]?
  public let version: Version?
  public let blockingAlert: BlockingAlert?
  
  public var minVersionNumber: Int {
    version?.ios?.minVersionNumber ?? 0
  }
  
  public var minVersionString: String {
    version?.ios?.minVersionString ?? ""
  }
  
  public var isSendCryptoV2Enabled: Bool {
    (features?["isSendCryptoV2Enabled"] as? Bool) ?? false
  }
  
  public var remoteLinks: RemoteLinks {
    RemoteLinks(config: features?["TERM_OF_SERVICE"]?.value as? [String: String])
  }
}

public struct RemoteLinks {
  private let config: [String: String]?
  
  init(config: [String: String]?) {
    self.config = config
  }
  
  public var esignatureLink: String? {
    config?["esignatureLink"] as? String
  }
  
  public var privacyPolicyLink: String? {
    config?["privacyPolicyLink"] as? String
  }
  
  public var termConditionLink: String? {
    config?["termConditionLink"] as? String
  }
  
  public var consumerAccountLink: String? {
    config?["consumerAccountLink"] as? String
  }
  
  public var patriotNoticeLink: String? {
    config?["patriotNoticeLink"] as? String
  }
}

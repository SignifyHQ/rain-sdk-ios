import Foundation
import LFUtilities
import AccountDomain

public struct AccountFeatureConfigData {
  enum AccessLevel: String, Codable {
    case LIVE, INTERNAL, DISABLED, EXPERIMENTAL, NONE
    
    init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let rawString = try container.decode(String.self)
      if let userType = AccessLevel(rawValue: rawString.uppercased()) {
        self = userType
      } else {
        self = .NONE
      }
    }
  }
  
  public var configJSON: String = "" {
    didSet {
      if let jsonData = configJSON.data(using: .utf8) {
        do {
          let obj = try JSONDecoder().decode(FeatureConfigModel.self, from: jsonData)
          self.featureConfig = obj
        } catch {
          log.debug(error.userFriendlyMessage)
        }
      }
    }
  }
  public var isLoading: Bool
  
  public var featureConfig: FeatureConfigModel?
  
  public init(configJSON: String, isLoading: Bool) {
    self.configJSON = configJSON
    self.isLoading = isLoading
  }
}

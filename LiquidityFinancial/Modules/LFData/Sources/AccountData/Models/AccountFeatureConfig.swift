import Foundation
import LFUtilities
import AccountDomain

public struct AccountFeatureConfig {
  
  public var featureConfig: FeatureConfigModel?
  
  public init(configJSON: String) {
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

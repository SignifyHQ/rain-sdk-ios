import Foundation
import FeatureFlagDomain

public struct APIListFeatureFlagResponse: Codable {
  public let total: Int
  public let data: [FeatureFlagModel]
  
}

extension APIListFeatureFlagResponse: ListFeatureFlagEntity {
  public var items: [FeatureFlagEntity] {
    data
  }
}

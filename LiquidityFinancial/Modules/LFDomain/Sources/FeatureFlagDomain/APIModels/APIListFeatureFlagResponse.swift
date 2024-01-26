import Foundation

public struct APIListFeatureFlagResponse: Codable {
  
  public let total: Int
  public let data: [FeatureFlagModel]
  
}

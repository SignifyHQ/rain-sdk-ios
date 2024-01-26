import Foundation

public struct FeatureFlagModel: Codable {
  public let id: String
  public let key: String
  public let productId: String?
  public let enabled: Bool
  public let description: String?
}

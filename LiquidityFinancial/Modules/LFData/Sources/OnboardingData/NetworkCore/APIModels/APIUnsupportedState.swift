import Foundation
import OnboardingDomain

public struct APIUnsupportedState: Codable, UnsupportedStateEntity {
  public var id: String
  public var countryCode: String
  public var stateCode: String
  public var stateName: String
  public var status: String
  public var description: String
  public var isRelease: Bool
  public var releasedAt: String?
  public var createdAt: String
  public var updatedAt: String
}

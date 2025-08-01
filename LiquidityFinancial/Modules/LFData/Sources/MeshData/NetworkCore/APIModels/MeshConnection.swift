import Foundation
import MeshDomain
import NetworkUtilities

public struct MeshConnection: MeshConnectionEntity, Parameterable {
  public var brokerType: String
  public var brokerName: String
  public var brokerLogoUrl: String?
  public var brokerIconUrl: String?
  public var brokerBase64Logo: String?
  public var accountId: String
  public var accountName: String
  public var accessToken: String
  public var refreshToken: String?
  public var expiresInSeconds: Int?
  public var meshAccountId: String?
  public var frontAccountId: String?
  public var fund: Double?
  public var cash: Double?
}

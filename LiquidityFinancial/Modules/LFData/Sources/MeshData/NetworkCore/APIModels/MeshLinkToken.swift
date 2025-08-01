import Foundation
import MeshDomain

public struct MeshLinkToken: MeshLinkTokenEntity, Decodable {
  public var linkToken: String
  public var brokerType: String?
  public var brokerName: String?
  public var brokerLogoUrl: String?
  public var brokerIconUrl: String?
  public var accountId: String?
  public var accountName: String?
  public var accessToken: String?
}

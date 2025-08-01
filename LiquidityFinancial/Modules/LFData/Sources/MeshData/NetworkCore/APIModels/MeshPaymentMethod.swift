import Foundation
import MeshDomain

public struct MeshPaymentMethod: MeshPaymentMethodEntity, Decodable {
  public var id: String {
    methodId
  }
  
  public var methodId: String
  public var brokerType: String
  public var brokerName: String
  public var brokerLogoUrl: String?
  public var brokerIconUrl: String?
  public var brokerBase64Logo: String?
  public var createdAt: String
  public var isConnectionExpired: Bool
  public var expiresAt: String?
  public var lastActiveAt: String?
}

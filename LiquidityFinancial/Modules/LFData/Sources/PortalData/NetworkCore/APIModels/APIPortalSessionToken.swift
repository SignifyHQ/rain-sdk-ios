import Foundation
import PortalDomain

public struct APIPortalSessionToken: PortalSessionTokenEntity, Decodable {
  public var clientSessionToken: String
}

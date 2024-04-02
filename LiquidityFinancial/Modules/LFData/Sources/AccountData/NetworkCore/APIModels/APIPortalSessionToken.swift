import AccountDomain
import Foundation

public struct APIPortalSessionToken: PortalSessionTokenEntity, Decodable {
  public var clientSessionToken: String
}

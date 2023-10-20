import Foundation
import NetspendDomain

public class APIAuthorizationCode: Decodable, AuthorizationCodeEntity {
  public var authorizationCode: String
}

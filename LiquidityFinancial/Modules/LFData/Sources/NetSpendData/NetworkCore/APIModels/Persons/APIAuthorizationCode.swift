import Foundation
import NetSpendDomain

public class APIAuthorizationCode: Decodable, AuthorizationCodeEntity {
  public var authorizationCode: String
}

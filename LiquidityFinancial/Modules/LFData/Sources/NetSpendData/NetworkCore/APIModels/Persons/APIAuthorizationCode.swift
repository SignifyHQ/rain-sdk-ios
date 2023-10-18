import Foundation
import BankDomain

public class APIAuthorizationCode: Decodable, AuthorizationCodeEntity {
  public var authorizationCode: String
}

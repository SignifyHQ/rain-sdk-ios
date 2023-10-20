import Foundation
import NetspendDomain

public struct APIAccountPersonData: Decodable, AccountPersonDataEntity {
  public let liquidityAccountId, externalAccountId, externalPersonId: String
}

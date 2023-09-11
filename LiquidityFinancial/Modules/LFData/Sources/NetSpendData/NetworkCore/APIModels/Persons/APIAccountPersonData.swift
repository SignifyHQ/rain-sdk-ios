import Foundation
import NetSpendDomain

public struct APIAccountPersonData: Decodable, AccountPersonDataEntity {
  public let liquidityAccountId, externalAccountId, externalPersonId: String
}

import Foundation
import BankDomain

public struct APIAccountPersonData: Decodable, AccountPersonDataEntity {
  public let liquidityAccountId, externalAccountId, externalPersonId: String
}

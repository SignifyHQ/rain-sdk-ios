import Foundation
import NetSpendDomain

public struct APIDepositResponse: DepositResponseEntity, Decodable {
  public let transactionId: String
}

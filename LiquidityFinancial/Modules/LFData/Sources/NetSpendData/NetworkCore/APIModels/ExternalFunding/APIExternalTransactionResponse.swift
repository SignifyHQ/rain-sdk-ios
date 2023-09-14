import Foundation
import NetSpendDomain

public struct APIExternalTransactionResponse: ExternalTransactionResponseEntity, Decodable {
  public let transactionId: String
  public let externalTransferId: String
}

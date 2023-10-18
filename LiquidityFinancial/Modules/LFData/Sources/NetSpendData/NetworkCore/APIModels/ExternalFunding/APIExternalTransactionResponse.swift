import Foundation
import BankDomain

public struct APIExternalTransactionResponse: ExternalTransactionResponseEntity, Decodable {
  public let transactionId: String
  public let externalTransferId: String
}

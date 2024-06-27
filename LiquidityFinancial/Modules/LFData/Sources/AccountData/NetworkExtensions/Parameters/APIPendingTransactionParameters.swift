import Foundation
import NetworkUtilities
import AccountDomain

public struct APIPendingTransactionParameters: Parameterable, PendingTransactionParametersEntity {
  public var transactionHash: String
  public var chainId: String
  public var fromAddress: String
  public var toAddress: String
  public var amount: Double
  public var currency: String
  public var status: String = "PENDING"
  public var contractAddress: String?
  public var decimal: Int
  public var gasPrice: Double = 0
  public var gasUsed: Double = 0
  public var transactionFee: Double
  
  public init(
    transactionHash: String,
    chainId: String,
    fromAddress: String,
    toAddress: String,
    amount: Double,
    currency: String,
    contractAddress: String?,
    decimal: Int,
    transactionFee: Double
  ) {
    self.transactionHash = transactionHash
    self.chainId = chainId
    self.fromAddress = fromAddress
    self.toAddress = toAddress
    self.amount = amount
    self.currency = currency
    self.contractAddress = contractAddress
    self.decimal = decimal
    self.transactionFee = transactionFee
  }
}

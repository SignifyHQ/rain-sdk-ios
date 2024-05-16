import Foundation
import NetworkUtilities
import RainDomain

public struct APIRainWithdrawalSignatureParameters: Parameterable, RainWithdrawalSignatureParametersEntity {
  public let chainId: Int
  public let token: String
  public let amount: String
  public let adminAddress: String
  public let recipientAddress: String
  
  public init(
    chainId: Int,
    token: String,
    amount: String,
    adminAddress: String,
    recipientAddress: String
  ) {
    self.chainId = chainId
    self.token = token
    self.amount = amount
    self.adminAddress = adminAddress
    self.recipientAddress = recipientAddress
  }
}

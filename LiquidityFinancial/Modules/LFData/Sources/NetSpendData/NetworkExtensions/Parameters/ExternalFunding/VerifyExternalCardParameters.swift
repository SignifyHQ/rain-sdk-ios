import Foundation
import NetworkUtilities
import BankDomain

public struct VerifyExternalCardParameters: Parameterable, VerifyExternalCardParametersEntity {
  public var transferAmount: Double
  public var cardId: String
  
  public init(transferAmount: Double, cardId: String) {
    self.transferAmount = transferAmount
    self.cardId = cardId
  }
}

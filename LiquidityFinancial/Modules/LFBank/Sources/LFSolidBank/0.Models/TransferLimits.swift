import Foundation

public struct TransferLimits {
  public let debitCard: [TransferLimitConfig]
  public let bankAccount: [TransferLimitConfig]
  public let sendToCard: [TransferLimitConfig]
  public let spending: [TransferLimitConfig]
  public let financialInstitutionsSpending: [TransferLimitConfig]
  
  public static let `default` = TransferLimits(transferLimitConfigs: [])
  
  init(transferLimitConfigs: [TransferLimitConfig]) {
    self.debitCard = transferLimitConfigs.filter({ $0.transferType == .card })
    self.bankAccount = transferLimitConfigs.filter({ $0.transferType == .bank })
    self.sendToCard = transferLimitConfigs.filter({ $0.transferType == .spendToCard })
    self.spending = transferLimitConfigs.filter({ $0.transferType == .spending })
    self.financialInstitutionsSpending = transferLimitConfigs.filter({ $0.transferType == .financialInstitutionsSpending })
  }
}

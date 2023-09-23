import Foundation

public struct TransferLimits {
  public let debitCard: [TransferLimitConfig]
  public let bankAccount: [TransferLimitConfig]
  
  public static let `default` = TransferLimits(transferLimitConfigs: [])
  
  init(transferLimitConfigs: [TransferLimitConfig]) {
    self.debitCard = transferLimitConfigs.filter({ $0.transferType == .card })
    self.bankAccount = transferLimitConfigs.filter({ $0.transferType == .bank })
  }
}

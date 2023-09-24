import Foundation
import LFLocalizable

enum TransferLimitSection {
  case cardDeposit
  case bankDeposit
  case cardWithdraw
  case bankWithdraw
  
  var title: String {
    switch self {
      case .cardDeposit:
        return LFLocalizable.TransferLimit.CardDeposit.title
      case .bankDeposit:
        return LFLocalizable.TransferLimit.BankDeposit.title
      case .cardWithdraw:
        return LFLocalizable.TransferLimit.CardWithdrawal.title
      case .bankWithdraw:
        return LFLocalizable.TransferLimit.BankWithdrawal.title
    }
  }
  
  var message: String {
    switch self {
      case .cardDeposit:
        return LFLocalizable.TransferLimit.CardDeposit.message
      case .bankDeposit:
        return LFLocalizable.TransferLimit.BankDeposit.message
      case .cardWithdraw:
        return LFLocalizable.TransferLimit.CardWithdrawal.message
      case .bankWithdraw:
        return LFLocalizable.TransferLimit.BankWithdrawal.message
    }
  }
}

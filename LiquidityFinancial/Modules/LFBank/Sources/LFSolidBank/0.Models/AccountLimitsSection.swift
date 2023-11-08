import Foundation
import LFLocalizable
import LFUtilities

enum AccountLimitsSection {
  case cardDeposit
  case bankDeposit
  case totalDeposit
  case cardWithdraw
  case bankWithdraw
  case totalWithdraw
  case spendingLimit
  
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
    case .totalDeposit:
      return LFLocalizable.TransferLimit.Deposit.TotallLimits.title(LFUtilities.cardName)
    case .spendingLimit:
      return LFLocalizable.TransferLimit.SpendingLimits.title
    case .totalWithdraw:
      return LFLocalizable.TransferLimit.Withdraw.TotallLimits.title
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
    case .totalDeposit:
      return LFLocalizable.TransferLimit.Deposit.TotallLimits.message
    case .spendingLimit:
      return LFLocalizable.TransferLimit.SpendingLimits.message
    case .totalWithdraw:
      return LFLocalizable.TransferLimit.Withdraw.TotallLimits.message
    }
  }
}

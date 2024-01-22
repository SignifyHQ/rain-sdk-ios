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
      return LFLocalizable.TransferLimit.Deposit.TotallLimits.title
    case .totalWithdraw:
      return LFLocalizable.TransferLimit.Withdraw.TotallLimits.title
    }
  }
  
  var message: String {
    switch self {
    case .cardDeposit:
      return LFLocalizable.TransferLimit.CardDeposit.message(LFUtilities.cardFullName)
    case .bankDeposit:
      return LFLocalizable.TransferLimit.BankDeposit.message(LFUtilities.cardFullName)
    case .cardWithdraw:
      return LFLocalizable.TransferLimit.CardWithdrawal.message(LFUtilities.cardFullName)
    case .bankWithdraw:
      return LFLocalizable.TransferLimit.BankWithdrawal.message(LFUtilities.cardFullName)
    case .totalDeposit:
      return LFLocalizable.TransferLimit.Deposit.TotallLimits.message(LFUtilities.cardFullName)
    case .totalWithdraw:
      return LFLocalizable.TransferLimit.Withdraw.TotallLimits.message(LFUtilities.cardFullName)
    }
  }
}

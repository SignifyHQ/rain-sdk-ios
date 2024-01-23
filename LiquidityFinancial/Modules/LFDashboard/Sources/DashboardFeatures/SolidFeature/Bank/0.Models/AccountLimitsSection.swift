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
      return L10N.Common.TransferLimit.CardDeposit.title
    case .bankDeposit:
      return L10N.Common.TransferLimit.BankDeposit.title
    case .cardWithdraw:
      return L10N.Common.TransferLimit.CardWithdrawal.title
    case .bankWithdraw:
      return L10N.Common.TransferLimit.BankWithdrawal.title
    case .totalDeposit:
      return L10N.Common.TransferLimit.Deposit.TotallLimits.title
    case .totalWithdraw:
      return L10N.Common.TransferLimit.Withdraw.TotallLimits.title
    }
  }
  
  var message: String {
    switch self {
    case .cardDeposit:
      return L10N.Common.TransferLimit.CardDeposit.message(LFUtilities.cardFullName)
    case .bankDeposit:
      return L10N.Common.TransferLimit.BankDeposit.message(LFUtilities.cardFullName)
    case .cardWithdraw:
      return L10N.Common.TransferLimit.CardWithdrawal.message(LFUtilities.cardFullName)
    case .bankWithdraw:
      return L10N.Common.TransferLimit.BankWithdrawal.message(LFUtilities.cardFullName)
    case .totalDeposit:
      return L10N.Common.TransferLimit.Deposit.TotallLimits.message(LFUtilities.cardFullName)
    case .totalWithdraw:
      return L10N.Common.TransferLimit.Withdraw.TotallLimits.message(LFUtilities.cardFullName)
    }
  }
}

import Foundation
import LFLocalizable
import LFUtilities

enum AccountLimitSection {
  case cardDeposit
  case bankDeposit
  case cardWithdraw
  case bankWithdraw
  case sendToCard
  case spendingLimit
  case financialInstitutionsLimit
  
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
    case .sendToCard:
      return L10N.Common.TransferLimit.SendToCard.title(LFUtilities.cardFullName)
    case .spendingLimit:
      return L10N.Common.TransferLimit.SpendingLimits.title
    case .financialInstitutionsLimit:
      return L10N.Common.TransferLimit.FinancialInstitutionsLimits.title
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
    case .sendToCard:
      return L10N.Common.TransferLimit.SendToCard.message
    case .spendingLimit:
      return L10N.Common.TransferLimit.SpendingLimits.message
    case .financialInstitutionsLimit:
      return L10N.Common.TransferLimit.FinancialInstitutionsLimits.message
    }
  }
}

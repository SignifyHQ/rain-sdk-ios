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
      return LFLocalizable.TransferLimit.CardDeposit.title
    case .bankDeposit:
      return LFLocalizable.TransferLimit.BankDeposit.title
    case .cardWithdraw:
      return LFLocalizable.TransferLimit.CardWithdrawal.title
    case .bankWithdraw:
      return LFLocalizable.TransferLimit.BankWithdrawal.title
    case .sendToCard:
      return LFLocalizable.TransferLimit.SendToCard.title(LFUtilities.cardFullName)
    case .spendingLimit:
      return LFLocalizable.TransferLimit.SpendingLimits.title
    case .financialInstitutionsLimit:
      return LFLocalizable.TransferLimit.FinancialInstitutionsLimits.title
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
    case .sendToCard:
      return LFLocalizable.TransferLimit.SendToCard.message
    case .spendingLimit:
      return LFLocalizable.TransferLimit.SpendingLimits.message
    case .financialInstitutionsLimit:
      return LFLocalizable.TransferLimit.FinancialInstitutionsLimits.message
    }
  }
}

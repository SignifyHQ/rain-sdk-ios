import Foundation
import LFLocalizable
import LFUtilities

enum TransferLimitSection {
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
        return LFLocalizable.TransferLimit.SendToCard.title(LFUtility.cardName)
      case .spendingLimit:
        return LFLocalizable.TransferLimit.SpendingLimits.title
      case .financialInstitutionsLimit:
        return LFLocalizable.TransferLimit.FinancialInstitutionsLimits.title
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
      case .sendToCard:
        return LFLocalizable.TransferLimit.SendToCard.message
      case .spendingLimit:
        return LFLocalizable.TransferLimit.SpendingLimits.message
      case .financialInstitutionsLimit:
        return LFLocalizable.TransferLimit.FinancialInstitutionsLimits.message
    }
  }
}

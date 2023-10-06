import Foundation
import SwiftUI
import LFLocalizable
import LFStyleGuide

public enum FundOption {
  case directDeposit
  case bankTransfers
  case debitDeposit
  case oneTime
  case debitDepositFunds
}

extension FundOption {
  
  var image: Image {
    switch self {
    case .directDeposit:
      return GenImages.CommonImages.Accounts.directDeposit.swiftUIImage
    case .bankTransfers:
      return GenImages.CommonImages.Accounts.bankTransfers.swiftUIImage
    case .debitDeposit, .debitDepositFunds:
      return GenImages.CommonImages.Accounts.debitDeposit.swiftUIImage
    case .oneTime:
      return GenImages.CommonImages.Accounts.oneTime.swiftUIImage
    }
  }
  
  var title: String {
    switch self {
    case .directDeposit:
      return LFLocalizable.AccountView.DirectDeposit.title
    case .bankTransfers:
      return LFLocalizable.AccountView.BankTransfers.title
    case .debitDeposit, .debitDepositFunds:
      return LFLocalizable.AccountView.DebitDeposits.title
    case .oneTime:
      return LFLocalizable.AccountView.OneTimeTransfers.title
    }
  }
  
  var subtitle: String {
    switch self {
    case .directDeposit:
      return LFLocalizable.AccountView.DirectDeposit.subtitle
    case .bankTransfers:
      return LFLocalizable.AccountView.BankTransfers.subtitle
    case .debitDeposit:
      return LFLocalizable.AccountView.DebitDeposits.subtitle
    case .oneTime:
      return LFLocalizable.AccountView.OneTimeTransfers.subtitle
    case .debitDepositFunds:
      return LFLocalizable.AccountView.DebitDepositsFunds.subtitle
    }
  }
  
  var navigation: AddFundsViewModel.Navigation {
    switch self {
    case .directDeposit:
      return .directDeposit
    case .bankTransfers:
      return .bankTransfers
    case .debitDeposit, .debitDepositFunds:
      return .addBankDebit
    case .oneTime:
      return .linkExternalBank
    }
  }
}

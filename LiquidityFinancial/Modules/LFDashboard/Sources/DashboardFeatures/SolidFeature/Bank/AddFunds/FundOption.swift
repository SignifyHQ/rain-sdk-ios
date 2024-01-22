import Foundation
import SwiftUI
import LFLocalizable
import LFStyleGuide

public enum FundOption {
  case directDeposit
  case bankTransfers
  case oneTime
}

extension FundOption {
  
  var image: Image {
    switch self {
    case .directDeposit:
      return GenImages.CommonImages.Accounts.directDeposit.swiftUIImage
    case .bankTransfers:
      return GenImages.CommonImages.Accounts.bankTransfers.swiftUIImage
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
    case .oneTime:
      return LFLocalizable.AccountView.OneTimeTransfers.subtitle
    }
  }
  
  var navigation: AddFundsViewModel.Navigation {
    switch self {
    case .directDeposit:
      return .directDeposit
    case .bankTransfers:
      return .bankTransfers
    case .oneTime:
      return .linkExternalBank
    }
  }
}

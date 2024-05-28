import Foundation
import LFLocalizable

enum WalletType {
  case internalWallet
  case externalWallet
  
  func getTitle(asset: String = .empty) -> String {
    switch self {
    case .internalWallet:
      return L10N.Common.CashTab.WithdrawBalance.internalWallet(asset)
    case .externalWallet:
      return L10N.Common.CashTab.WithdrawBalance.externalWallet
    }
  }
}

import LFLocalizable
import LFStyleGuide
import SwiftUI

public enum FilterTransactionType: String, CaseIterable, Identifiable {
  public var id: String { rawValue }
  
  case deposit
  case withdraw
  case purchase
  
  public var title: String {
    switch self {
    case .deposit:
      L10N.Common.Transactions.Filters.TypeFilter.Addition.title
    case .withdraw:
      L10N.Common.Transactions.Filters.TypeFilter.Withdrawal.title
    case .purchase:
      L10N.Common.Transactions.Filters.TypeFilter.Purchase.title
    }
  }
  
  public var image: Image {
    switch self {
    case .deposit:
      GenImages.Images.icoFilterDeposit.swiftUIImage
    case .withdraw:
      GenImages.Images.icoFilterWithdrawal.swiftUIImage
    case .purchase:
      GenImages.Images.icoFilterPurchase.swiftUIImage
    }
  }
  
  var transactionType: String {
    rawValue.uppercased()
  }
}

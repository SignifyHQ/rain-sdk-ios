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
      L10N.Common.TransactionFilters.TypeFilter.Addition.title
    case .withdraw:
      L10N.Common.TransactionFilters.TypeFilter.Withdrawal.title
    case .purchase:
      L10N.Common.TransactionFilters.TypeFilter.Purchase.title
    }
  }
  
  public var image: Image {
    switch self {
    case .deposit:
      GenImages.CommonImages.icFiltersDeposit.swiftUIImage
    case .withdraw:
      GenImages.CommonImages.icFiltersWithdrawal.swiftUIImage
    case .purchase:
      GenImages.CommonImages.icFiltersPurchase.swiftUIImage
    }
  }
  
  var transactionType: String {
    rawValue.uppercased()
  }
}

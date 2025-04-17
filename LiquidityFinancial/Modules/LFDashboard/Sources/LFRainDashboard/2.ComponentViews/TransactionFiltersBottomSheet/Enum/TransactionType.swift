import LFLocalizable
import LFStyleGuide
import SwiftUI

enum FilterTransactionType: String, CaseIterable, Identifiable {
  var id: String { rawValue }
  
  case deposit
  case withdrawal
  case purchase
  
  var title: String {
    switch self {
    case .deposit:
      L10N.Common.TransactionFilters.TypeFilter.Addition.title
    case .withdrawal:
      L10N.Common.TransactionFilters.TypeFilter.Withdrawal.title
    case .purchase:
      L10N.Common.TransactionFilters.TypeFilter.Purchase.title
    }
  }
  
  var image: Image {
    switch self {
    case .deposit:
      GenImages.CommonImages.icFiltersDeposit.swiftUIImage
    case .withdrawal:
      GenImages.CommonImages.icFiltersWithdrawal.swiftUIImage
    case .purchase:
      GenImages.CommonImages.icFiltersPurchase.swiftUIImage
    }
  }
}

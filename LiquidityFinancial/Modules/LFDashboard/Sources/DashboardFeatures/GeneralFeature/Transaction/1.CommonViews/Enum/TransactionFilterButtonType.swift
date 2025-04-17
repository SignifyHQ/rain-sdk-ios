import LFLocalizable
import LFStyleGuide
import SwiftUI

public enum TransactionFilterButtonType: String, CaseIterable, Identifiable {
  public var id: String {
    rawValue
  }
  
  case all
  case type
  case currency
  
  var image: Image? {
    switch self {
    case .all:
      GenImages.CommonImages.icFilters.swiftUIImage
    default:
      nil
    }
  }
  
  var title: String? {
    switch self {
    case .type:
      L10N.Common.TransactionFilters.TypeFilter.title
    case .currency:
      L10N.Common.TransactionFilters.CurrencyFilter.title
    case .all:
      nil
    }
  }
}

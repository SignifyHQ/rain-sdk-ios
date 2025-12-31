import LFLocalizable
import LFStyleGuide
import SwiftUI

public enum TransactionsFilterButtonType: String, CaseIterable, Identifiable {
  public var id: String {
    rawValue
  }
  
  case all
  case type
  case currency
  
  public var image: Image? {
    switch self {
    case .all:
      GenImages.Images.icoFilter.swiftUIImage
    default:
      nil
    }
  }
  
  public var title: String? {
    switch self {
    case .type:
      L10N.Common.Transactions.Filters.TypeFilter.title
    case .currency:
      L10N.Common.Transactions.Filters.CurrencyFilter.title
    case .all:
      nil
    }
  }
}

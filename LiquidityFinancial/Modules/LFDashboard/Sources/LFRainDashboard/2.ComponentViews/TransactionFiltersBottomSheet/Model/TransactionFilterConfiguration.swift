import Foundation
import GeneralFeature

struct TransactionFilterConfiguration: Equatable {
  var selectedTypes: Set<FilterTransactionType> = []
  var selectedCurrencies: Set<AssetModel> = []
  
  var transactionTypesFilter: [String]? {
    selectedTypes
      .map { type in
        type.transactionType
      }
      .nilIfEmpty
  }
  
  var transactionCurrenciesFilter: String? {
    selectedCurrencies
      .map { asset in
        asset.id
      }
      .joined(separator: ",")
      .nilIfEmpty
  }
}

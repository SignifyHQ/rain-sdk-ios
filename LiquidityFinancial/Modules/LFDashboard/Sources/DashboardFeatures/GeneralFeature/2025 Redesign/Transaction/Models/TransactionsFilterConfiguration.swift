import Foundation

public struct TransactionsFilterConfiguration: Equatable {
  public var selectedTypes: Set<FilterTransactionType> = []
  public var selectedCurrencies: Set<AssetModel> = []
  
  public init() {}
  
  public var transactionTypesFilter: [String]? {
    selectedTypes
      .map { type in
        type.transactionType
      }
      .nilIfEmpty
  }
  
  public var transactionCurrenciesFilter: [String]? {
    selectedCurrencies
      .compactMap { asset in
        asset.type?.rawValue
      }
      .nilIfEmpty
  }
}

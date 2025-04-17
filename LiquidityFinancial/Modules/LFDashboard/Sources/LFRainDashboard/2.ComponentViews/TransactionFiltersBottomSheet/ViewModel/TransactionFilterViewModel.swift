import Factory
import Foundation
import GeneralFeature

class TransactionFilterViewModel: ObservableObject {
  @LazyInjected(\.portalStorage) var portalStorage
  
  @Published var filterConfiguration: TransactionFilterConfiguration = TransactionFilterConfiguration()
  @Published var assetModelList: [AssetModel] = []
  
  @Published var didApplyChanges: Bool = false
  
  init() {
    observePortalAssets()
  }
  
  func apply() {
    didApplyChanges.toggle()
  }
  
  func reset() {
    filterConfiguration.selectedTypes.removeAll()
    filterConfiguration.selectedCurrencies.removeAll()
  }
  
  func toggle(
    filter type: FilterTransactionType
  ) {
    if filterConfiguration.selectedTypes.contains(type) {
      filterConfiguration.selectedTypes.remove(type)
    } else {
      filterConfiguration.selectedTypes.insert(type)
    }
  }
  
  func toggle(
    filter asset: AssetModel
  ) {
    if filterConfiguration.selectedCurrencies.contains(asset) {
      filterConfiguration.selectedCurrencies.remove(asset)
    } else {
      filterConfiguration.selectedCurrencies.insert(asset)
    }
  }
  
  private func observePortalAssets(
  ) {
    portalStorage
      .cryptoAssets()
      .receive(on: DispatchQueue.main)
      .map { assets in
        assets
          .compactMap {
            let assetModel = AssetModel(portalAsset: $0)
            
            // Filter out tokens of unsupported type
            guard assetModel.type != nil && !assetModel.id.isEmpty
            else {
              return nil
            }
            
            return assetModel
          }
          .sorted {
            ($0.type?.rawValue ?? "") < ($1.type?.rawValue ?? "")
          }
      }
      .assign(to: &$assetModelList)
  }
}

struct TransactionFilterConfiguration: Equatable {
  var selectedTypes: Set<FilterTransactionType> = []
  var selectedCurrencies: Set<AssetModel> = []
}

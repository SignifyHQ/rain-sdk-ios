import Factory
import Foundation

public class TransactionFilterViewModel: ObservableObject {
  //@LazyInjected(\.portalStorage) var portalStorage
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @Published public var filterConfiguration: TransactionFilterConfiguration = TransactionFilterConfiguration()
  @Published var assetModelList: [AssetModel] = []
  
  @Published public var didApplyChanges: Bool = false
  
  public init() {
    subscribeToCollateralChanges()
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
  
  private func subscribeToCollateralChanges() {
    accountDataManager
      .collateralContractSubject
      .compactMap { rainCollateral in
        rainCollateral?
          .tokensEntity
          .compactMap { rainToken in
            let assetModel = AssetModel(rainCollateralAsset: rainToken)
            
            // Filter out tokens of unsupported type
            guard assetModel.type != nil && !assetModel.id.isEmpty
            else {
              return nil
            }
            
            // FRNT exclusive experience, only show FRNT token if user has balance
            guard assetModel.type != .frnt || assetModel.availableBalance > 0
            else {
              return nil
            }
            
            return assetModel
          }
          .sorted {
            let oneIsPrio = $0.type == .frnt
            let twoIsPrio = $1.type == .frnt
            
            if oneIsPrio != twoIsPrio {
              return oneIsPrio
            }
            
            return ($0.type?.rawValue ?? "") < ($1.type?.rawValue ?? "")
          }
      }
      .assign(to: &$assetModelList)
  }
  
//  private func observePortalAssets(
//  ) {
//    portalStorage
//      .cryptoAssets()
//      .receive(on: DispatchQueue.main)
//      .map { assets in
//        assets
//          .compactMap {
//            let assetModel = AssetModel(portalAsset: $0)
//            // Filter out tokens of unsupported type
//            guard assetModel.type != nil && !assetModel.id.isEmpty && assetModel.type != .usdte
//            else {
//              return nil
//            }
//            
//            return assetModel
//          }
//          .sorted {
//            ($0.type?.rawValue ?? "") < ($1.type?.rawValue ?? "")
//          }
//      }
//      .assign(to: &$assetModelList)
//  }
}

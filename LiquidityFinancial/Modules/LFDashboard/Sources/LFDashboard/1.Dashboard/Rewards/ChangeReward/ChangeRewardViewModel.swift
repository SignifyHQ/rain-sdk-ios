import Foundation
import AccountDomain
import LFUtilities
import Factory
import LFTransaction
import BaseDashboard

@MainActor
class ChangeRewardViewModel: ObservableObject {
  @Published var assetModels: [AssetModel]
  @Published var selectedAssetModel: AssetModel
  
  init(assetModels: [AssetModel], selectedAssetModel: AssetModel) {
    self.assetModels = assetModels
    self.selectedAssetModel = selectedAssetModel
  }
}

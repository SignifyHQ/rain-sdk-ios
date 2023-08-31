import Foundation
import SwiftUI
import AccountDomain
import LFUtilities
import Factory
import Combine
import DashboardRepository

@MainActor
final class AssetsViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var assets: [AssetModel] = []
  @Published var navigation: Navigation?
  
  private var cancellable: Set<AnyCancellable> = []
  
  init(assets: Published<[AssetModel]>.Publisher, isLoading: Published<Bool>.Publisher) {
    assets
      .assign(to: \.assets, on: self)
      .store(in: &cancellable)
    
    isLoading
      .assign(to: \.isLoading, on: self)
      .store(in: &cancellable)
  }
  
  func onClickedAssetButton(assetType: AssetType) {
    guard let asset = assets.first(where: { $0.type == assetType }) else {
      return
    }
    switch assetType {
    case .usd:
      navigation = .usd(asset)
    default:
      navigation = .crypto(asset)
    }
  }
}

  // MARK: - API
extension AssetsViewModel {
  
}

  // MARK: - Types
extension AssetsViewModel {
  enum Navigation {
    case usd(AssetModel)
    case crypto(AssetModel)
  }
}

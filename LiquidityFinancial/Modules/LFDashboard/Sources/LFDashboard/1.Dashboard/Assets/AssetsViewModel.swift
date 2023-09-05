import Foundation
import SwiftUI
import AccountDomain
import LFUtilities
import Factory
import Combine
import BaseDashboard

@MainActor
final class AssetsViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var assets: [AssetModel] = []
  @Published var navigation: Navigation?
  
  private var cancellable: Set<AnyCancellable> = []
  
  init(isLoading: Published<Bool>.Publisher) {
    accountDataManager
      .accountsSubject.map({ accounts in
        accounts.map({ AssetModel(account: $0) })
      })
      .assign(to: \.assets, on: self)
      .store(in: &cancellable)
    
    isLoading
      .assign(to: \.isLoading, on: self)
      .store(in: &cancellable)
  }
  
  func onClickedAsset(asset: AssetModel) {
    if asset.type == .usd {
      navigation = .usd(asset)
    } else {
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

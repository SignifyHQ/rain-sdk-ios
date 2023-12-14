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
  @LazyInjected(\.dashboardRepository) var dashboardRepository
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var assets: [AssetModel] = []
  @Published var navigation: Navigation?
  
  private var cancellable: Set<AnyCancellable> = []
  
  init() {
    accountDataManager
      .accountsSubject.map({ accounts in
        accounts.map({ AssetModel(account: $0) })
          .filter({ $0.type != .usd })
      })
      .assign(to: \.assets, on: self)
      .store(in: &cancellable)
  }
  
  func onClickedAsset(asset: AssetModel) {
    if asset.type == .usd {
      return
    }
    navigation = .crypto(asset)
  }
  
  func refresh() async {
    async let cryptoAccountsEntity = self.dashboardRepository.getCryptoAccounts()
    do {
      let accounts = try await cryptoAccountsEntity
      
      self.accountDataManager.accountsSubject.send(accounts)
    } catch {
      toastMessage = error.localizedDescription
    }
  }
}

  // MARK: - Types
extension AssetsViewModel {
  enum Navigation {
    case crypto(AssetModel)
  }
}

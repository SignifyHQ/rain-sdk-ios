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
      })
      .assign(to: \.assets, on: self)
      .store(in: &cancellable)
  }
  
  func onClickedAsset(asset: AssetModel) {
    if asset.type == .usd {
      navigation = .usd(asset)
    } else {
      navigation = .crypto(asset)
    }
  }
  
  func refresh() async {
    async let fiatAccountsEntity = self.dashboardRepository.getFiatAccounts()
    async let cryptoAccountsEntity = self.accountRepository.getAccount(currencyType: Constants.CurrencyType.crypto.rawValue)
    do {
      let fiatAccounts = try await fiatAccountsEntity
      let cryptoAccounts = try await cryptoAccountsEntity
      //let accounts = fiatAccounts + cryptoAccounts
      
      // TODO: Will implement crypto account in another PR
      //self.accountDataManager.accountsSubject.send(accounts)
      self.accountDataManager.accountsSubject.send(fiatAccounts)
    } catch {
      toastMessage = error.localizedDescription
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

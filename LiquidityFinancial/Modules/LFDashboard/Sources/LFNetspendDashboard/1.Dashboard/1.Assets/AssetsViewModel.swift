import Foundation
import SwiftUI
import AccountDomain
import LFUtilities
import Factory
import Combine
import DashboardComponents

@MainActor
final class AssetsViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var assets: [AssetModel] = []
  @Published var navigation: Navigation?
  
  private var cancellable: Set<AnyCancellable> = []
  
  let dashboardRepository: DashboardRepository
  init(dashboardRepository: DashboardRepository) {
    self.dashboardRepository = dashboardRepository
    
    accountDataManager
      .accountsSubject
      .receive(on: DispatchQueue.main)
      .map({ accounts in
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
    async let cryptoAccountsEntity = self.dashboardRepository.getCryptoAccounts()
    do {
      let fiatAccounts = try await fiatAccountsEntity
      let cryptoAccounts = try await cryptoAccountsEntity
      let accounts = fiatAccounts + cryptoAccounts
      
      self.accountDataManager.accountsSubject.send(accounts)
    } catch {
      toastMessage = error.userFriendlyMessage
    }
  }
}

  // MARK: - Types
extension AssetsViewModel {
  enum Navigation {
    case usd(AssetModel)
    case crypto(AssetModel)
  }
}

import Factory
import AccountData
import SwiftUI
import Combine
import LFStyleGuide
import LFLocalizable

@MainActor
class SavedWalletAddressListViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @Published var wallets: [APIWalletAddress] = []
  @Published var isLoading: Bool = false
  @Published var toastData: ToastData?
  @Published var navigation: Navigation?
  
  private var subscribers: Set<AnyCancellable> = []
  
  var accountId: String {
    guard let tokenEntities = accountDataManager.collateralContract?.tokensEntity else {
      return .empty
    }
    
    let asset = tokenEntities
      .compactMap { rainToken in
        AssetModel(rainCollateralAsset: rainToken)
      }
      .first(
        where: { asset in
          asset.type == .usdc
        }
      )
    return asset?.id ?? .empty
  }
  
  init() {
    getSavedWallets()
    observeWalletAddressesChanges() 
  }
}

// MARK: Handle UI/UX
extension SavedWalletAddressListViewModel {
  func showCreatedWalletToast(nickname: String) {
    toastData = .init(type: .success, title: L10N.Common.SaveNewWalletAddress.Success.message(nickname))
  }
  
  func showDeletedWalletToast(nickname: String) {
    toastData = .init(type: .success, title: L10N.Common.RemoveWalletAddress.Success.message(nickname))
  }
}

// MARK: Binding Observables
extension SavedWalletAddressListViewModel {
  func observeWalletAddressesChanges() {
    accountDataManager
      .subscribeWalletAddressesChanged({ [weak self] wallets in
        guard let self = self else {
          return
        }
        self.wallets = wallets.map({ APIWalletAddress(entity: $0) })
      })
      .store(in: &subscribers)
  }
}

// MARK: Handle Interactions
extension SavedWalletAddressListViewModel {
  func onCreateNewWalletTapped() {
    navigation = .createWalletAddress
  }
  
  func onEditWalletTap(wallet: APIWalletAddress) {
    navigation = .editWalletAddress(wallet: wallet)
  }
}

// MARK: - APIs Handler
extension SavedWalletAddressListViewModel {
  private func getSavedWallets() {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      
      do {
        let response = try await accountRepository.getWalletAddresses()
        let walletAddresses = response.map({ APIWalletAddress(entity: $0) })
        wallets = walletAddresses
        accountDataManager.storeWalletAddresses(response)
      } catch {
        toastData = ToastData(type: .error, title: error.userFriendlyMessage)
      }
    }
  }
}

// MARK: Private Enums
extension SavedWalletAddressListViewModel {
  enum Navigation {
    case createWalletAddress
    case editWalletAddress(wallet: APIWalletAddress)
  }
}

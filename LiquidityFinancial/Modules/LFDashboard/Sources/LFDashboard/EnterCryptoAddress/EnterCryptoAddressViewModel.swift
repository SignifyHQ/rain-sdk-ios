import SwiftUI
import AccountData
import LFLocalizable
import LFUtilities
import Factory
import AccountDomain
import CodeScanner
import Combine

@MainActor
final class EnterCryptoAddressViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @Published var isPerformingAction = false
  @Published var numberOfShakes = 0
  @Published var inlineError: String?
  @Published var toastMessage: String?
  @Published var inputValue: String = ""
  @Published var isShowingScanner: Bool = false
  @Published var navigation: Navigation?
  @Published var wallets: [APIWalletAddress] = []
  @Published var walletsFilter: [APIWalletAddress] = []
  @Published var walletSelected: APIWalletAddress?
  @Published var isFetchingData: Bool = false
  
  let amount: Double
  let account: LFAccount
  
  private var subscribers: Set<AnyCancellable> = []
  
  init(account: LFAccount, amount: Double) {
    self.account = account
    self.amount = amount
    
    getSavedWallets()
    accountDataManager
      .subscribeWalletAddressesChanged({ [weak self] wallets in
        guard let self = self else {
          return
        }
        self.wallets = wallets.map({ APIWalletAddress(entity: $0) })
        self.filterWalletAddressList()
      })
      .store(in: &subscribers)
  }
  
  var isActionAllowed: Bool {
    !inputValue.trimWhitespacesAndNewlines().isEmpty
  }
  
  func continueButtonTapped() {
    Haptic.impact(.light).generate()
    navigation = .confirm
  }
  
  func scanAddressTap() {
    isShowingScanner = true
  }
  
  func clearValue() {
    inputValue = "".trimWhitespacesAndNewlines()
    walletSelected = nil
  }
  
  func handleScan(result: Result<ScanResult, ScanError>) {
    isShowingScanner = false
    switch result {
    case let .success(result):
      inputValue = result.string
    case let .failure(error):
      log.error("Scanning failed: \(error.localizedDescription)")
    }
  }
}

extension EnterCryptoAddressViewModel {
  
  func getSavedWallets() {
    isFetchingData = true
    Task { @MainActor in
      defer {
        isFetchingData = false
      }
      do {
        let response = try await accountRepository.getWalletAddresses(accountId: account.id)
        let walletAddresses = response.map({ APIWalletAddress(entity: $0) })
        wallets = walletAddresses
        walletsFilter = walletAddresses
        accountDataManager.storeWalletAddresses(response)
      } catch {
        toastMessage = error.localizedDescription
      }
      isFetchingData = false
    }
  }
  
  func filterWalletAddressList() {
    if walletSelected?.address != inputValue {
      walletSelected = nil
    }
    guard walletSelected == nil else {
      return
    }
    walletsFilter = wallets.filter { wallet in
      guard let nickname = wallet.nickname else {
        return false
      }
      return nickname.lowercased().hasPrefix(inputValue.lowercased())
    }
    wallets.forEach { wallet in
      if wallet.address == inputValue {
        walletsFilter = [wallet]
        walletSelected = wallet
        return
      }
    }
  }
  
  func selectedWallet(wallet: APIWalletAddress) {
    walletSelected = wallet
    inputValue = wallet.address
  }
  
  func editWalletTapped(wallet: APIWalletAddress) {
    navigation = .editWalletAddress(wallet: wallet)
  }
  
  func deleteWalletTapped(wallet: APIWalletAddress) {
    
  }
  
}

extension EnterCryptoAddressViewModel {
  enum Navigation {
    case confirm
    case editWalletAddress(wallet: APIWalletAddress)
  }
}

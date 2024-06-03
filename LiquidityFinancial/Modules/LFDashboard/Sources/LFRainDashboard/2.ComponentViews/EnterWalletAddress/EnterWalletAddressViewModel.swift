import SwiftUI
import AccountData
import LFLocalizable
import LFUtilities
import Factory
import AccountDomain
import CodeScanner
import Combine
import GeneralFeature

@MainActor
final class EnterWalletAddressViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  
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
  @Published var showIndicator = false
  @Published var popup: Popup?
  
  let kind: Kind
  let asset: AssetModel
  
  private var subscribers: Set<AnyCancellable> = []
  
  var selectedNickname: String {
    guard let walletSelected, walletSelected.address == inputValue else {
      return .empty
    }
    return walletSelected.nickname ?? .empty
  }
  
  init(asset: AssetModel, kind: Kind) {
    self.asset = asset
    self.kind = kind
    
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
    switch kind {
    case .sendCrypto:
      navigation = .enterAmount(
        type: .sendCrypto(
          address: inputValue,
          nickname: selectedNickname
        )
      )
    case .withdrawCollateral:
      navigation = .enterAmount(
        type: .withdrawCollateral(
          address: inputValue,
          nickname: selectedNickname,
          shouldSaveAddress: true
        )
      )
    case let .withdrawReward(balance):
      navigation = .enterAmount(
        type: .withdrawReward(
          address: inputValue,
          nickname: selectedNickname,
          balance: balance,
          shouldSaveAddress: true
        )
      )
    }
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
      log.error("Scanning failed: \(error.userFriendlyMessage)")
    }
  }
}

extension EnterWalletAddressViewModel {
  
  func getSavedWallets() {
    Task { @MainActor in
      defer { isFetchingData = false }
      isFetchingData = true
      do {
        let response = try await accountRepository.getWalletAddresses()
        let walletAddresses = response.map({ APIWalletAddress(entity: $0) })
        wallets = walletAddresses
        walletsFilter = walletAddresses
        accountDataManager.storeWalletAddresses(response)
      } catch {
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func filterWalletAddressList() {
    if walletSelected?.address != inputValue {
      walletSelected = nil
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
    popup = .delete(wallet)
  }
  
  func handleDelete(wallet: APIWalletAddress) {
    Task { @MainActor in
      defer { showIndicator = false }
      showIndicator = true
      do {
        let response = try await accountRepository.deleteWalletAddresses(
          walletAddress: wallet.address
        )
        if response.success {
          accountDataManager.removeWalletAddress(id: wallet.id)
          toastMessage = L10N.Common.EnterCryptoAddressView.DeleteSuccess.message
          popup = nil
        }
      } catch {
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func hidePopup() {
    popup = nil
  }
  
}

extension EnterWalletAddressViewModel {
  enum Navigation {
    case enterAmount(type: MoveCryptoInputViewModel.Kind)
    case editWalletAddress(wallet: APIWalletAddress)
  }
  
  enum Popup {
    case delete(APIWalletAddress)
  }
  
  enum Kind {
    case sendCrypto
    case withdrawCollateral
    case withdrawReward(balance: Double)
    
    func getTitle(asset: String) -> String {
      switch self {
      case .sendCrypto:
        return L10N.Common.EnterCryptoAddressView.title(asset)
      case .withdrawReward, .withdrawCollateral:
        return L10N.Common.EnterWalletAddressView.WithdrawBalance.title
      }
    }
    
    func getTextFieldTitle(asset: String) -> String {
      switch self {
      case .sendCrypto:
        return L10N.Common.EnterCryptoAddressView.WalletAddress.title(asset)
      case .withdrawReward, .withdrawCollateral:
        return L10N.Common.EnterWalletAddressView.WithdrawBalance.textFieldTitle
      }
    }
  }
}

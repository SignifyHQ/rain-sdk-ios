import SwiftUI
import AccountData
import LFLocalizable
import LFUtilities
import Factory
import AccountDomain
import CodeScanner
import Combine
import GeneralFeature
import LFStyleGuide

@MainActor
final class WalletAddressEntryViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @Published var numberOfShakes = 0
  @Published var inlineError: String?
  @Published var toastData: ToastData?
  @Published var inputValue: String = ""
  @Published var isShowingScanner: Bool = false
  @Published var navigation: Navigation?
  @Published var wallets: [APIWalletAddress] = []
  @Published var walletsFilter: [APIWalletAddress] = []
  @Published var walletSelected: APIWalletAddress?
  @Published var isFetchingData: Bool = false
  @Published var showIndicator = false
  @Published var popup: Popup?
  
  var selectedNickname: String {
    guard let walletSelected, walletSelected.address == inputValue else {
      return .empty
    }
    return walletSelected.nickname ?? .empty
  }
  
  var isActionAllowed: Bool {
    !inputValue.trimWhitespacesAndNewlines().isEmpty
  }
  
  private var subscribers: Set<AnyCancellable> = []
  
  let kind: Kind
  let asset: AssetModel
  
  init(asset: AssetModel, kind: Kind) {
    self.asset = asset
    self.kind = kind
    
    getSavedWallets()
    observeWalletAddressesChanges()
  }
}

// MARK: - Binding Observables
private extension WalletAddressEntryViewModel {
  func observeWalletAddressesChanges() {
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
}

// MARK: Handle UI/UX
extension WalletAddressEntryViewModel {
  func showDeletedWalletToast(nickname: String) {
    toastData = .init(type: .success, title: L10N.Common.RemoveWalletAddress.Success.message(nickname))
  }
}

// MARK: - Handling Interations
extension WalletAddressEntryViewModel {
  func onContinueButtonTap() {
    Haptic.impact(.light).generate()
    navigation = .enterAmount
  }
  
  func onScanButtonTap() {
    isShowingScanner = true
  }
  
  func handleScan(result: Result<ScanResult, ScanError>) {
    isShowingScanner = false
    switch result {
    case let .success(result):
      inputValue = result.string.parseWalletAddress()
    case let .failure(error):
      log.error("Scanning failed: \(error.localizedDescription)")
      switch error {
      case .permissionDenied:
        self.popup = .openSettings
      default:
        self.toastData = .init(type: .error, title: error.userFriendlyMessage)
      }
    }
  }
  
  func clearValue() {
    inputValue = "".trimWhitespacesAndNewlines()
    walletSelected = nil
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
  
  func onWalletSelect(wallet: APIWalletAddress) {
    walletSelected = wallet
    inputValue = wallet.address
  }
  
  func onEditWalletTap(wallet: APIWalletAddress) {
    navigation = .editWalletAddress(wallet: wallet)
  }
}

// MARK: - APIs Handler
extension WalletAddressEntryViewModel {
  private func getSavedWallets() {
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
        toastData = ToastData(type: .error, title: error.userFriendlyMessage)
      }
    }
  }
}

// MARK: Helpers
extension WalletAddressEntryViewModel {
  func openSettings() {
    if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
       UIApplication.shared.canOpenURL(settingsUrl) {
      UIApplication.shared.open(settingsUrl)
    }
  }
}

// MARK: Private Enums
extension WalletAddressEntryViewModel {
  enum Navigation {
    case enterAmount
    case editWalletAddress(wallet: APIWalletAddress)
  }
  
  enum Kind {
    case sendCrypto
    case withdrawCollateral
    case withdrawReward(balance: Double)
    
    func getTitle(asset: String) -> String {
      switch self {
      case .sendCrypto:
        return L10N.Common.WalletAddressInput.SendAsset.title(asset)
      case .withdrawReward:
        return L10N.Common.WalletAddressInput.WithdrawReward.title
      case .withdrawCollateral:
        return L10N.Common.WalletAddressInput.WithdrawToken.title
      }
    }
    
    func getTextFieldTitle(asset: String) -> String {
      switch self {
      case .sendCrypto:
        return L10N.Common.WalletAddressInput.Input.assetTitle(asset)
      case .withdrawReward, .withdrawCollateral:
        return L10N.Common.WalletAddressInput.Input.title
      }
    }
  }
  
  enum Popup: Identifiable {
    var id: Self { self }
    
    case openSettings
    case showLearnMore
  }
}

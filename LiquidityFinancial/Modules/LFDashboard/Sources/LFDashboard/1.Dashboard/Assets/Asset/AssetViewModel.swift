import Foundation
import AccountDomain
import LFUtilities
import Factory

@MainActor
class AssetViewModel: ObservableObject {
  @Published var account: LFAccount?
  @Published var cryptoBalance: String = "0.00"
  @Published var usdBalance: String = "0.00"
  @Published var loading: Bool = false
  @Published var showTransferSheet: Bool = false
  @Published var cryptoPrice: String = "0.00"
  @Published var changePercent: Double = 0
  @Published var showCryptoDetail: Bool = false
  @Published var toastMessage: String = ""
  @Published var isLoading: Bool = false
  @Published var navigation: Navigation?
  @Published var sheet: SheetPresentation?

  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository

  private let guestHandler: () -> Void

  var isPositivePrice: Bool {
    changePercent > 0
  }

  var changePercentAbsString: String {
    String(format: "%.2f%%", abs(changePercent))
  }
  
  var currencyType: String {
    "CRYPTO"
  }
  
  init(guestHandler: @escaping () -> Void) {
    self.guestHandler = guestHandler
  }
}

extension AssetViewModel {
  func onAppear() {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      let accounts = try await accountRepository.getAccount(currencyType: currencyType)
      guard let account = accounts.first else {
        return
      }
      self.account = account
    }
  }
  
  func onClickedBuyButton() {
    Haptic.impact(.light).generate()
    navigation = .buyCrypto
  }
  
  func onClickedSellButton() {
    Haptic.impact(.light).generate()
    navigation = .sellCrypto
  }
  
  func transferButtonTapped() {
    Haptic.impact(.light).generate()
    showTransferSheet = true
  }
  
  func receiveButtonTapped() {
    showTransferSheet = false
    navigation = .receiveCrypto
  }
  
  func sendButtonTapped() {
    showTransferSheet = false
    navigation = .sendCrypto
  }
  
  func walletRowTapped() {
    Haptic.impact(.soft).generate()
    if false { // userManager.isGuest TODO: - Will be updated later
      guestHandler()
    } else {
      sheet = .wallet
    }
  }
}

extension AssetViewModel {
  
  enum Navigation {
    case buyCrypto
    case sellCrypto
    case receiveCrypto
    case sendCrypto
  }
  
  enum SheetPresentation: Identifiable {
    case wallet
    
    var id: String {
      switch self {
      case .wallet: return "wallet"
      }
    }
  }
}

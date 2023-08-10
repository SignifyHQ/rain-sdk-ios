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
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository

  var isPositivePrice: Bool {
    changePercent > 0
  }

  var changePercentAbsString: String {
    String(format: "%.2f%%", abs(changePercent))
  }
  
  var currencyType: String {
    "CRYPTO"
  }
}

extension AssetViewModel {
  
  func onAppear() {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      let accounts = try await accountRepository.getAccount(currencyType: currencyType)
      guard var account = accounts.first else {
        return
      }
      log.info("Account ")
      self.account = account
    }
  }
  
  func transferButtonTapped() {
    Haptic.impact(.light).generate()
    showTransferSheet = true
  }
  
  func receiveButtonTapped() {
    showTransferSheet = false
    navigation = .receive
  }
}

extension AssetViewModel {
  
  enum Navigation {
    case receive
  }
  
}

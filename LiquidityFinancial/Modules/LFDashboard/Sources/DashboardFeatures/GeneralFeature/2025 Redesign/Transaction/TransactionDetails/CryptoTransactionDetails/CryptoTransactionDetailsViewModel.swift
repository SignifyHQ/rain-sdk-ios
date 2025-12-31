import Foundation
import UIKit
import Factory
import Services
import EnvironmentService
import LFUtilities

class CryptoTransactionDetailsViewModel: ObservableObject {
  @LazyInjected(\.environmentService) var environmentService
  
  @Published var showIndicator: Bool = false
  @Published var navigation: Navigation?
  @Published var showSaveWalletAddressPopup = false

  let transaction: TransactionModel
  let transactionInfos: [TransactionInformation]
  var isNewAddress: Bool = false
  var walletAddress: String = ""
  
  init(transaction: TransactionModel, transactionInfos: [TransactionInformation], isNewAddress: Bool, address: String) {
    self.transaction = transaction
    self.transactionInfos = transactionInfos
    self.isNewAddress = isNewAddress
    self.walletAddress = address
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.showSaveWalletAddressPopup = isNewAddress
    }
  }
  
  func goToReceiptScreen(cryptoReceipt: CryptoReceipt) {
    navigation = .receipt(cryptoReceipt)
  }
  
  func dismissPopup() {
    showSaveWalletAddressPopup = false
  }

  func navigatedToEnterWalletNicknameScreen() {
    showSaveWalletAddressPopup = false
    navigation = .saveAddress(address: walletAddress)
  }
  
  func hashNetworkUrl(hash: String) -> String {
    let urlString = environmentService.networkEnvironment == .productionLive
    ? PublicConfigs.HashNetwork.prodUrl
    : PublicConfigs.HashNetwork.devUrl
    return urlString + hash
  }
}

// MARK: Helpers
extension CryptoTransactionDetailsViewModel {
  func openURL(urlString: String?) {
    guard
      let urlString,
      let url = URL(string: urlString)
    else { return }
    
    UIApplication.shared.open(url)
  }
}

extension CryptoTransactionDetailsViewModel {
  enum Navigation {
    case receipt(CryptoReceipt)
    case saveAddress(address: String)
  }
}

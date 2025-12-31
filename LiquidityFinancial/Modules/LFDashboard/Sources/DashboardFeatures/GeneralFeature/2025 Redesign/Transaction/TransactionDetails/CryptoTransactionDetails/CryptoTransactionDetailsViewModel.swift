import Foundation
import Factory
import Services

class CryptoTransactionDetailsViewModel: ObservableObject {
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
}

extension CryptoTransactionDetailsViewModel {
  enum Navigation {
    case receipt(CryptoReceipt)
    case saveAddress(address: String)
  }
}

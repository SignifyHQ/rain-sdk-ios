import Foundation
import Factory
import Services
import ZerohashData

class CryptoTransactionDetailViewModel: ObservableObject {
  @Published var showIndicator: Bool = false
  @Published var toastMessage: String?
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
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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

extension CryptoTransactionDetailViewModel {
  enum Navigation {
    case receipt(CryptoReceipt)
    case saveAddress(address: String)
  }
}

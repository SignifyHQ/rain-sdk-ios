import Foundation
import Factory
import LFServices
import ZerohashData

class CryptoTransactionDetailViewModel: ObservableObject {
  
  @Published var showIndicator: Bool = false
  @Published var toastMessage: String?
  @Published var navigation: Navigation?
  
  let transaction: TransactionModel
  let transactionInfos: [TransactionInformation]
  var isNewAddress: Bool = false
  var walletAddress: String = ""
  
  @Published var showSaveWalletAddressPopup = false
  
  init(transaction: TransactionModel, transactionInfos: [TransactionInformation], isNewAddress: Bool, address: String) {
    self.transaction = transaction
    self.transactionInfos = transactionInfos
    self.isNewAddress = isNewAddress
    self.walletAddress = address
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      self.showSaveWalletAddressPopup = isNewAddress
    }
  }
  
  func goToReceiptScreen() {
    navigation = .receipt
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
    case receipt
    case saveAddress(address: String)
  }
}

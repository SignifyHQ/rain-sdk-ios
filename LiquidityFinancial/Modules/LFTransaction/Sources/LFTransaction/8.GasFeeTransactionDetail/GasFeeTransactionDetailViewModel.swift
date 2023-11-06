import Foundation
import Services
import LFLocalizable
import LFUtilities
import LFStyleGuide

final class GasFeeTransactionDetailViewModel: ObservableObject {
  @Published var navigation: Navigation?
  let transaction: TransactionModel
  
  init(transaction: TransactionModel) {
    self.transaction = transaction
  }
  
  func goToReceiptScreen(receiptType: ReceiptType) {
    if let donationReceipt = transaction.donationReceipt, receiptType == .donation {
      navigation = .donationReceipt(donationReceipt)
    } else if let cryptoReceipt = transaction.cryptoReceipt, receiptType == .crypto {
      navigation = .cryptoReceipt(cryptoReceipt)
    }
  }
}

// MARK: - Types
extension GasFeeTransactionDetailViewModel {
  enum Navigation {
    case cryptoReceipt(CryptoReceipt)
    case donationReceipt(DonationReceipt)
  }
}

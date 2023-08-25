import Foundation
import LFServices
import LFLocalizable
import LFUtilities
import LFStyleGuide

final class PurchaseTransactionDetailViewModel: ObservableObject {
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

// MARK: - View Helpers
extension PurchaseTransactionDetailViewModel {
  var cardInformation: TransactionCardInformation {
    TransactionCardInformation(
      cardType: transaction.rewards?.type.transactionCardType ?? .unknow,
      amount: amountValue,
      message: transaction.rewards?.description ?? LFLocalizable.TransactionCard.Purchase.message(
        rewardAmount,
        amountValue,
        LFUtility.appName
      ),
      activityItem: LFLocalizable.TransactionCard.ShareCrypto.title(rewardAmount, LFUtility.appName, LFUtility.shareAppUrl),
      stickerUrl: transaction.rewards?.stickerUrl,
      color: transaction.rewards?.backgroundColor
    )
  }
  
  var rewardAmount: String {
    transaction.rewards?.amount?.formattedAmount(minFractionDigits: 3) ?? .empty
  }
  
  var amountValue: String {
    transaction.amount.formattedAmount(prefix: Constants.CurrencyUnit.usd.rawValue, minFractionDigits: 2)
  }
}

// MARK: - Types
extension PurchaseTransactionDetailViewModel {
  enum Navigation {
    case cryptoReceipt(CryptoReceipt)
    case donationReceipt(DonationReceipt)
  }
}

import Foundation
import Services
import LFLocalizable
import LFUtilities
import LFStyleGuide

final class RewardTransactionDetailViewModel: ObservableObject {
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
extension RewardTransactionDetailViewModel {
  var cardInformation: TransactionCardInformation {
    TransactionCardInformation(
      cardType: transaction.rewards?.type.transactionCardType ?? (LFUtilities.cryptoEnabled ? .crypto : .unknow),
      amount: amountValue,
      rewardAmount: amountValue,
      message: LFLocalizable.TransactionCard.Purchase.message(rewardAmount, amountValue, LFUtilities.appName),
      activityItem: LFLocalizable.TransactionCard.ShareCrypto.title(rewardAmount, LFUtilities.appName, LFUtilities.shareAppUrl),
      stickerUrl: transaction.rewards?.stickerUrl,
      color: transaction.rewards?.backgroundColor
    )
  }
  
  var rewardAmount: String {
    transaction.rewards?.amount?.formattedAmount(minFractionDigits: 2) ?? .empty
  }
  
  var amountValue: String {
    transaction.amount.formattedUSDAmount()
  }
}

// MARK: - Types
extension RewardTransactionDetailViewModel {
  enum Navigation {
    case cryptoReceipt(CryptoReceipt)
    case donationReceipt(DonationReceipt)
  }
}

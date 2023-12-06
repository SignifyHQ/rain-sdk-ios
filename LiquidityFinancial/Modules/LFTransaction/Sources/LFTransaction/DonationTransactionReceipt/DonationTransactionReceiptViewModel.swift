import Foundation
import LFUtilities
import LFLocalizable

@MainActor
final class DonationTransactionReceiptViewModel: ObservableObject {
  enum OpenSafariType: Identifiable {
    var id: String {
      switch self {
      case .disclosure(let url):
        return url.absoluteString
      }
    }
    
    case disclosure(URL)
  }
  
  let receiptData: [TransactionRowData]
  
  init(accountID: String, receipt: DonationReceipt) {
    receiptData = [
      .init(title: LFLocalizable.DonationReceipt.TransactionNumber.title, value: receipt.id),
      .init(
        title: LFLocalizable.DonationReceipt.Reward.title,
        value: receipt.rewardsDonation?.formattedUSDAmount()
      ),
      .init(
        title: LFLocalizable.DonationReceipt.Roundup.title,
        value: receipt.roundUpDonation?.formattedUSDAmount()
      ),
      .init(
        title: LFLocalizable.DonationReceipt.OneTime.title,
        value: receipt.oneTimeDonation?.formattedUSDAmount()
      ),
      .init(
        title: LFLocalizable.DonationReceipt.Total.title,
        value: receipt.totalDonation?.formattedUSDAmount()
      ),
      .init(
        title: LFLocalizable.DonationReceipt.Fee.title,
        value: receipt.fee?.formattedUSDAmount() ?? "$0"
      ),
      .init(
        title: LFLocalizable.DonationReceipt.DateAndTime.title,
        value: receipt.createdAt.serverToTransactionDisplay(includeYear: true)
      ),
      .init(title: LFLocalizable.CryptoReceipt.AccountID.title, value: accountID)
    ]
  }
}

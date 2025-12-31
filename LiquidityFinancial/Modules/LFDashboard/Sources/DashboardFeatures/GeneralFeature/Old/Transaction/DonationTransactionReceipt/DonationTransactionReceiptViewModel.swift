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
      .init(title: L10N.Common.DonationReceipt.TransactionNumber.title, value: receipt.id),
      .init(
        title: L10N.Common.DonationReceipt.Reward.title,
        value: receipt.rewardsDonation?.formattedUSDAmount()
      ),
      .init(
        title: L10N.Common.DonationReceipt.Roundup.title,
        value: receipt.roundUpDonation?.formattedUSDAmount()
      ),
      .init(
        title: L10N.Common.DonationReceipt.OneTime.title,
        value: receipt.oneTimeDonation?.formattedUSDAmount()
      ),
      .init(
        title: L10N.Common.DonationReceipt.Total.title,
        value: receipt.totalDonation?.formattedUSDAmount()
      ),
      .init(
        title: L10N.Common.DonationReceipt.Fee.title,
        value: receipt.fee?.formattedUSDAmount() ?? "$0"
      ),
      .init(
        title: L10N.Common.DonationReceipt.DateAndTime.title,
        value: receipt.createdAt.parsingDateStringToNewFormat(toDateFormat: .fullTransactionDate)
      ),
      .init(title: L10N.Common.CryptoReceipt.AccountID.title, value: accountID)
    ]
  }
}

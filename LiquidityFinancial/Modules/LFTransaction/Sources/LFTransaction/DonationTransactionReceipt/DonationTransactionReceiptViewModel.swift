import Foundation
import LFUtilities
import LFLocalizable

@MainActor
final class DonationTransactionReceiptViewModel: ObservableObject {
  let receiptData: [TransactionRowData]
  
  init(accountID: String, receipt: DonationReceipt) {
    receiptData = [
      .init(title: LFLocalizable.DonationReceipt.TransactionNumber.title, value: receipt.id),
      .init(
        title: LFLocalizable.DonationReceipt.Reward.title,
        value: receipt.rewardsDonation?.formattedAmount(prefix: Constants.CurrencyUnit.usd.symbol, minFractionDigits: 2)
      ),
      .init(
        title: LFLocalizable.DonationReceipt.Roundup.title,
        value: receipt.roundUpDonation?.formattedAmount(prefix: Constants.CurrencyUnit.usd.symbol, minFractionDigits: 2)
      ),
      .init(
        title: LFLocalizable.DonationReceipt.OneTime.title,
        value: receipt.oneTimeDonation?.formattedAmount(prefix: Constants.CurrencyUnit.usd.symbol, minFractionDigits: 2)
      ),
      .init(
        title: LFLocalizable.DonationReceipt.Total.title,
        value: receipt.totalDonation?.formattedAmount(prefix: Constants.CurrencyUnit.usd.symbol, minFractionDigits: 2)
      ),
      .init(
        title: LFLocalizable.DonationReceipt.Fee.title,
        value: receipt.fee?.formattedAmount(prefix: Constants.CurrencyUnit.usd.symbol) ?? "$0"
      ),
      .init(
        title: LFLocalizable.DonationReceipt.DateAndTime.title,
        value: receipt.createdAt.serverToTransactionDisplay(includeYear: true)
      ),
      .init(title: LFLocalizable.CryptoReceipt.AccountID.title, value: accountID)
    ]
  }
}

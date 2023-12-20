import Foundation
import LFUtilities
import LFLocalizable

@MainActor
final class CryptoTransactionReceiptViewModel: ObservableObject {
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
  
  init(accountID: String, receipt: CryptoReceipt) {
    let secondRowData = receipt.orderType.isTransfer
    ? TransactionRowData(title: LFLocalizable.CryptoReceipt.Currency.title, value: receipt.currency)
    : TransactionRowData(title: LFLocalizable.CryptoReceipt.TradingPair.title, value: receipt.tradingPair)

    receiptData = [
      .init(title: LFLocalizable.CryptoReceipt.OrderNumber.title, value: receipt.id),
      secondRowData,
      .init(title: LFLocalizable.CryptoReceipt.OrderType.title, value: receipt.orderType.title),
      .init(
        title: LFLocalizable.CryptoReceipt.Amount.title,
        markValue: receipt.size?.formattedAmount(
          minFractionDigits: Constants.FractionDigitsLimit.crypto.minFractionDigits,
          maxFractionDigits: Constants.FractionDigitsLimit.crypto.maxFractionDigits
        ),
        value: receipt.currency),
      .init(
        title: LFLocalizable.CryptoReceipt.ExchangeRate.title,
        markValue: receipt.exchangeRate?.formattedUSDAmount(),
        value: Constants.CurrencyUnit.usd.description
      ),
      .init(
        title: LFLocalizable.CryptoReceipt.TransactionValue.title,
        markValue: receipt.transactionValue?.formattedUSDAmount(),
        value: Constants.CurrencyUnit.usd.description
      ),
      .init(
        title: LFLocalizable.CryptoReceipt.Fee.title,
        markValue: receipt.fee?.formattedUSDAmount() ?? "$0",
        value: Constants.CurrencyUnit.usd.description
      ),
      .init(title: LFLocalizable.CryptoReceipt.DateAndTime.title, value: receipt.createdAt.serverToReceiptDisplay()),
      .init(title: LFLocalizable.CryptoReceipt.AccountID.title, markValue: accountID)
    ]
  }
}

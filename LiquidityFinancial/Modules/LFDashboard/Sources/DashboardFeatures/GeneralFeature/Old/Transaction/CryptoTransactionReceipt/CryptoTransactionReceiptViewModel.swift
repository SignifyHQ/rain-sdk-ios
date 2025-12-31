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
    ? TransactionRowData(title: L10N.Common.CryptoReceipt.Currency.title, value: receipt.currency)
    : TransactionRowData(title: L10N.Common.CryptoReceipt.TradingPair.title, value: receipt.tradingPair)

    receiptData = [
      .init(title: L10N.Common.CryptoReceipt.OrderNumber.title, value: receipt.id),
      secondRowData,
      .init(title: L10N.Common.CryptoReceipt.OrderType.title, value: receipt.orderType.title),
      .init(
        title: L10N.Common.CryptoReceipt.Amount.title,
        markValue: receipt.size?.formattedAmount(
          minFractionDigits: Constants.FractionDigitsLimit.crypto.minFractionDigits,
          maxFractionDigits: Constants.FractionDigitsLimit.crypto.maxFractionDigits
        ),
        value: receipt.currency),
      .init(
        title: L10N.Common.CryptoReceipt.ExchangeRate.title,
        markValue: receipt.exchangeRate?.formattedUSDAmount(),
        value: Constants.CurrencyUnit.usd.description
      ),
      .init(
        title: L10N.Common.CryptoReceipt.TransactionValue.title,
        markValue: receipt.transactionValue?.formattedUSDAmount(),
        value: Constants.CurrencyUnit.usd.description
      ),
      .init(
        title: L10N.Common.CryptoReceipt.Fee.title,
        markValue: receipt.fee?.formattedUSDAmount() ?? "$0",
        value: Constants.CurrencyUnit.usd.description
      ),
      .init(
        title: L10N.Common.CryptoReceipt.DateAndTime.title,
        value: receipt.createdAt.parsingDateStringToNewFormat(toDateFormat: .fullReceiptDateTime) ?? .empty
      ),
      .init(title: L10N.Common.CryptoReceipt.AccountID.title, markValue: accountID)
    ]
  }
}

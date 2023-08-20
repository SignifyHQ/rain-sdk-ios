import Foundation
import LFUtilities
import LFLocalizable

@MainActor
final class CryptoTransactionReceiptViewModel: ObservableObject {
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
        markValue: receipt.size?.formattedAmount(minFractionDigits: 2),
        value: receipt.currency),
      .init(
        title: LFLocalizable.CryptoReceipt.ExchangeRate.title,
        markValue: receipt.exchangeRate?.formattedAmount(prefix: Constants.CurrencyUnit.usd.symbol, minFractionDigits: 2),
        value: Constants.CurrencyUnit.usd.description
      ),
      .init(
        title: LFLocalizable.CryptoReceipt.TransactionValue.title,
        markValue: receipt.transactionValue?.formattedAmount(prefix: Constants.CurrencyUnit.usd.symbol, minFractionDigits: 2),
        value: Constants.CurrencyUnit.usd.description
      ),
      .init(
        title: LFLocalizable.CryptoReceipt.Fee.title,
        markValue: receipt.fee?.formattedAmount(prefix: Constants.CurrencyUnit.usd.symbol) ?? "$0",
        value: Constants.CurrencyUnit.usd.description
      ),
      .init(title: LFLocalizable.CryptoReceipt.DateAndTime.title, value: receipt.completedAt?.serverToTransactionDisplay(includeYear: true)),
      .init(title: LFLocalizable.CryptoReceipt.AccountID.title, markValue: accountID)
    ]
  }
}

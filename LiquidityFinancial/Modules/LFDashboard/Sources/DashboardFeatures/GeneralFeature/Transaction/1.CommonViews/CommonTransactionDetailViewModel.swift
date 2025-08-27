import SwiftUI
import AccountService
import Factory
import LFUtilities
import LFLocalizable
import LFStyleGuide

@MainActor
public final class CommonTransactionDetailViewModel: ObservableObject {
  enum OpenSafariType: Identifiable {
    var id: String {
      switch self {
      case .disclosure(let url):
        return url.absoluteString
      }
    }
    
    case disclosure(URL)
  }
  
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  let disclosureString = L10N.Custom.TransactionDetail.RewardDisclosure.description
  let termsLink = L10N.Common.TransactionDetail.RewardDisclosure.Links.terms
  
  let transaction: TransactionModel
  let isCryptoBalance: Bool
  
  public init(transaction: TransactionModel, isCryptoBalance: Bool) {
    self.transaction = transaction
    self.isCryptoBalance = isCryptoBalance
  }
  
  var isDonationsCard: Bool {
    LFUtilities.charityEnabled
  }
  
  var navigationTitle: String? {
    transaction.type.title.capitalized
  }
  
  var descriptionDisplay: String {
    transaction.titleDisplay.uppercased()
  }
  
  var transactionDate: String {
    transaction.transactionDateInLocalZone(includeYear: true)
  }
  
  var cryptoIconImage: Image? {
    guard let currency = transaction.currency,
          let type = AssetType(rawValue: currency),
          type != .usd
    else {
      return nil
    }
    
    return type.icon
  }
  
  var colorForType: Color {
    transaction.colorForType
  }
  
  var fontForType: SwiftUI.Font {
    if transaction.isCryptoTransaction {
      return Fonts.bold.swiftUIFont(size: 50)
    }
    return Fonts.medium.swiftUIFont(size: 40)
  }
  
  var amountValue: String {
    transaction.amount.formattedAmount(
      prefix: transaction.isCryptoTransaction ? nil : Constants.CurrencyUnit.usd.rawValue,
      minFractionDigits: transaction.isCryptoTransaction ? Constants.FractionDigitsLimit.crypto.minFractionDigits : Constants.FractionDigitsLimit.fiat.minFractionDigits,
      maxFractionDigits: transaction.isCryptoTransaction ? Constants.FractionDigitsLimit.crypto.maxFractionDigits : Constants.FractionDigitsLimit.fiat.maxFractionDigits
    )
  }
  
  var currentBalance: Double? {
    transaction.currentBalance
  }
  
  var balanceValue: String {
    let cryptoCurrency = transaction.currency ?? .empty
    let balance = transaction.currentBalance?.formattedAmount(
      prefix: transaction.isCryptoTransaction ? nil : Constants.CurrencyUnit.usd.symbol,
      minFractionDigits: transaction.isCryptoTransaction ? Constants.FractionDigitsLimit.crypto.minFractionDigits : Constants.FractionDigitsLimit.fiat.minFractionDigits,
      maxFractionDigits: transaction.isCryptoTransaction ? Constants.FractionDigitsLimit.crypto.maxFractionDigits : Constants.FractionDigitsLimit.fiat.minFractionDigits
    ) ?? .empty
    return transaction.isCryptoTransaction ? "\(balance) \(cryptoCurrency.uppercased())" : balance
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func getUrl(for link: String) -> URL? {
    switch link {
    case termsLink:
      return URL(string: LFUtilities.termsURL)
    default:
      return nil
    }
  }
}

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
  
  let disclosureString = LFLocalizable.TransactionDetail.RewardDisclosure.description
  let termsLink = LFLocalizable.TransactionDetail.RewardDisclosure.Links.terms
  
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
    transaction.title?.capitalized
  }
  
  var descriptionDisplay: String {
    transaction.descriptionDisplay.uppercased()
  }
  
  var transactionDate: String {
    transaction.transactionDateInLocalZone(includeYear: true)
  }
  
  var cryptoIconImage: Image? {
    guard let currency = transaction.currency, let type = CurrencyType(rawValue: currency) else {
      return nil
    }
    return type.filledImage
  }
  
  var colorForType: Color {
    transaction.colorForType
  }
  
  var amountValue: String {
    transaction.amount.formattedAmount(
      prefix: transaction.isCryptoTransaction ? nil : Constants.CurrencyUnit.usd.rawValue,
      minFractionDigits: 2
    )
  }
  
  var currentBalance: Double? {
    transaction.currentBalance
  }
  
  var balanceValue: String {
    let cryptoCurrency = transaction.currency ?? .empty
    let balance = transaction.currentBalance?.formattedAmount(
      prefix: isCryptoBalance ? nil : Constants.CurrencyUnit.usd.symbol,
      minFractionDigits: 2
    ) ?? .empty
    return isCryptoBalance ? "\(balance) \(cryptoCurrency.uppercased())" : balance
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

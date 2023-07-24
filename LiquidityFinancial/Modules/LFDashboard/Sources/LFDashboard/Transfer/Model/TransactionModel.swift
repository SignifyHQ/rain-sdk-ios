import Foundation

struct TransactionModel: Codable, Identifiable, Equatable {
  var id: String?
  var txnType: TransactionType?
  var title: String?
  var amount: String?
  var transferType: TransferType = .unknown
  var subType: String?
  var description: String?
  var accountId: String?
  var balance: String?
  var createdAt: String?
  var txnDate: String?
  var estimatedTxnDate: String?
  var ach: ACH?
  var enrichedData: EnrichedData?
  var currency: String?
  var status: TransactionStatus?
  var quotedCurrency: String?
  var quotedPrice: String?
  var buy: Buy?
  var sell: Sell?
  /// A field populated on crypto transactions with `txnType == .reward`. It will detail the amount spent on the purchase that triggered this reward.
  var purchaseAmount: String?
  var gasFee: String?
  var donationCharityFundraiser: Fundraiser?
  var donationType: DonationType?
  var donationsBalance: String?
  var rewards: Rewards?

  var personName: String?
  var profileImageUrl: String?
  var cancellationDate: String?
  var platformTxnType: PlatformTransactionType = .other

  var trxPrice: String? {
    let value: String?
    var currency: String?
    switch transferType {
    case .buy:
      value = buy?.quotedPrice.nilIfEmpty
      currency = buy?.quotedCurrency.nilIfEmpty
    case .sell:
      value = sell?.quotedPrice.nilIfEmpty
      currency = sell?.quotedCurrency.nilIfEmpty
    default:
      value = quotedPrice?.nilIfEmpty
      currency = quotedCurrency?.nilIfEmpty
    }
    guard let value = value else {
      return nil
    }
    if currency == "USD" {
      currency = "$"
    }
    return value.formattedAmount(prefix: currency, minFractionDigits: 3, maxFractionDigits: 3, absoluteValue: true)
  }

  var formattedAmmount: String? {
    let prefix = isCashTransaction ? "$" : nil
    let fractionDigits = isCashTransaction ? 2 : 3
    return amount?.formattedAmount(prefix: prefix, minFractionDigits: fractionDigits, maxFractionDigits: fractionDigits, absoluteValue: true)
  }

  var formattedBalance: String? {
    let prefix = isCashTransaction ? "$" : nil
    let fractionDigits = isCashTransaction ? 2 : 3
    return balance?.formattedAmount(prefix: prefix, minFractionDigits: fractionDigits, maxFractionDigits: fractionDigits, absoluteValue: true)
  }

  var isPositiveAmount: Bool {
    (amount?.asDouble ?? 0) > 0
  }

  var isCashTransaction: Bool {
    guard let currencyType = currency else {
      return true
    }
    if currencyType == "USD" || currencyType == "$" {
      return true
    } else {
      return false
    }
  }

  func transactionDateInLocalZone(includeYear: Bool = false) -> String {
    guard let transDate = createdAt?.nilIfEmpty else {
      return ""
    }
    return transDate.serverToTransactionDisplay(includeYear: includeYear)
  }

  static func == (lhs: TransactionModel, rhs: TransactionModel) -> Bool {
    lhs.id == rhs.id
  }
}

// MARK: - Types

extension TransactionModel {
  struct ACH: Codable {
    let transferId: String?
    let contactId: String?
    let name: String?
  }

  struct PhysicalCheck: Codable {
    let transferId: String?
    let contactId: String?
    let name: String?
  }

  struct Merchant: Codable {
    let merchantName: String?
    let merchantCity: String?
    let merchantState: String?
    let merchantCountry: String?
    let postalCode: String?
    let merchantCategory: String?
  }

  struct MerchantData: Codable {
    let name: String?
    let email: String?
    let phone: String?
    let website: String?
    let logo: String?
    let address: AddressModel?
    let merchantCategory: String?
  }

  struct EnrichedData: Codable {
    var merchant: MerchantData?
  }

  struct Buy: Codable {
    let quotedPrice: String
    let quotedCurrency: String
  }

  struct Sell: Codable {
    let quotedPrice: String
    let quotedCurrency: String
  }
}

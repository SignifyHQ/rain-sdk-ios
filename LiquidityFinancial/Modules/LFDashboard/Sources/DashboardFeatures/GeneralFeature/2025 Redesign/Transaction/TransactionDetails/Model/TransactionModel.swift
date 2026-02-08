import Foundation
import AccountDomain
import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable

public struct TransactionModel: Identifiable, Hashable, Equatable {
  public var id: String
  public var accountId: String
  public var title: String?
  public let enrichedMerchantName: String?
  public let enrichedMerchantIcon: String?
  public let enrichedMerchantCategory: String?
  public var currency: String?
  public var localCurrency: String?
  public var description: String?
  public var amount: Double
  public var localAmount: Double?
  public var currentBalance: Double?
  public var fee: Double?
  public var type: TransactionType
  public var status: TransactionStatus?
  public var completedAt: String?
  public var createdAt: String
  public var updateAt: String
  public var contractAddress: String?
  public var transactionHash: String?
  
  var note: TransactionNote?
  var rewards: TransactionReward?
  var receipt: TransactionReceipt?
  var externalTransaction: ExternalTransaction?
  
  public init(
    id: String,
    accountId: String,
    title: String? = nil,
    enrichedMerchantName: String? = nil,
    enrichedMerchantIcon: String? = nil,
    enrichedMerchantCategory: String? = nil,
    currency: String? = nil,
    localCurrency: String? = nil,
    description: String? = nil,
    amount: Double,
    localAmount: Double? = nil,
    currentBalance: Double? = nil,
    fee: Double? = nil,
    type: TransactionType,
    status: TransactionStatus? = nil,
    completedAt: String? = nil,
    createdAt: String,
    updateAt: String,
    contractAddress: String? = nil,
    transactionHash: String? = nil,
    note: TransactionNote? = nil,
    rewards: TransactionReward? = nil,
    receipt: TransactionReceipt? = nil,
    externalTransaction: ExternalTransaction? = nil
  ) {
    self.id = id
    self.accountId = accountId
    self.title = title
    self.enrichedMerchantName = enrichedMerchantName
    self.enrichedMerchantIcon = enrichedMerchantIcon
    self.enrichedMerchantCategory = enrichedMerchantCategory
    self.currency = currency
    self.localCurrency = localCurrency
    self.description = description
    self.amount = amount
    self.localAmount = localAmount
    self.currentBalance = currentBalance
    self.fee = fee
    self.type = type
    self.status = status
    self.completedAt = completedAt
    self.createdAt = createdAt
    self.updateAt = updateAt
    self.transactionHash = transactionHash
    self.rewards = rewards
    self.receipt = receipt
    self.externalTransaction = externalTransaction
    self.note = note
    self.contractAddress = contractAddress
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  public static func == (lhs: TransactionModel, rhs: TransactionModel) -> Bool {
    return lhs.id == rhs.id
  }
}

// MARK: - View Helpers
public extension TransactionModel {
  var transactionRowImage: Image? {
    switch type {
    case .purchase, .refund:
      return GenImages.Images.icoPurchaseTransaction.swiftUIImage
    default:
      if let currencySymbol = currency,
         let asset = AssetType(rawValue: currencySymbol),
         asset == .frnt {
        return asset.transactionIcon
      }
      
      return Image(type.assetName)
    }
  }
  
  var transactionIcon: Image? {
    switch type {
    case .purchase, .refund:
      GenImages.Images.icoPurchaseTransaction.swiftUIImage
    default:
      cryptoIconImage
    }
  }
  
  var isACHTransaction: Bool {
    guard let transactionType = externalTransaction?.transactionType else {
      return false
    }
    return transactionType == Constants.TransactionType.ach.rawValue
  }
  
  var titleDisplay: String {
    switch type {
    case .withdraw, .deposit:
      return descriptionDisplay
    default:
      guard let title = title,
            !title.isEmpty
      else {
        return descriptionDisplay
      }
      
      return title.trimWhitespacesAndNewlines()
    }
  }
  
  var typeDisplay: String {
    switch type {
    case .withdraw, .cryptoWithdraw:
      return L10N.Common.TransactionDetails.Header.Withdrawal.title(currency ?? .empty)
    case .deposit, .cryptoDeposit:
      return L10N.Common.TransactionDetails.Header.Deposit.title(currency ?? .empty)
    default:
      guard let title = title,
            !title.isEmpty
      else {
        return descriptionDisplay
      }
      
      return title.trimWhitespacesAndNewlines()
    }
  }
  
  var subtitle: String {
    if let status = status {
      return (status == .pending || status == .declined) ? status.localizedDescription() : transactionDateInLocalZone()
    }
    
    return TransactionStatus.unknown.localizedDescription()
  }
  
  var amountFormatted: String {
    amount.formattedAmount(
      prefix: isCryptoTransaction ? nil : Constants.CurrencyUnit.usd.symbol,
      minFractionDigits: isCryptoTransaction
      ? Constants.FractionDigitsLimit.crypto.minFractionDigits
      : Constants.FractionDigitsLimit.fiat.minFractionDigits,
      maxFractionDigits: isCryptoTransaction
      ? Constants.FractionDigitsLimit.crypto.maxFractionDigits
      : Constants.FractionDigitsLimit.fiat.maxFractionDigits
    )
  }
  
  var localAmountFormatted: String? {
    guard currency != localCurrency
    else {
      return nil
    }
    
    return localAmount?.formattedAmount(
      prefix: localCurrency,
      minFractionDigits: Constants.FractionDigitsLimit.fiat.minFractionDigits,
      maxFractionDigits: Constants.FractionDigitsLimit.fiat.maxFractionDigits
    )
  }
  
  var balanceFormatted: String? {
    currentBalance?.formattedAmount(
      prefix: isCryptoTransaction ? nil : Constants.CurrencyUnit.usd.symbol,
      minFractionDigits: isCryptoTransaction
      ? Constants.FractionDigitsLimit.crypto.minFractionDigits
      : Constants.FractionDigitsLimit.fiat.minFractionDigits,
      maxFractionDigits: isCryptoTransaction
      ? Constants.FractionDigitsLimit.crypto.maxFractionDigits
      : Constants.FractionDigitsLimit.fiat.maxFractionDigits
    )
  }
  
  var descriptionDisplay: String {
    description?.trimWhitespacesAndNewlines() ?? ""
  }
  
  var cryptoReceipt: CryptoReceipt? {
    guard let receipt = receipt else {
      return nil
    }
    return CryptoReceipt(
      id: receipt.id,
      accountId: receipt.accountId,
      fee: receipt.fee,
      createdAt: createdAt,
      completedAt: receipt.completedAt,
      tradingPair: receipt.tradingPair,
      currency: receipt.currency,
      orderType: receipt.orderType,
      size: receipt.size,
      exchangeRate: receipt.exchangeRate,
      transactionValue: receipt.transactionValue
    )
  }
  
  var donationReceipt: DonationReceipt? {
    guard let receipt = receipt else {
      return nil
    }
    return DonationReceipt(
      id: receipt.id,
      accountId: receipt.accountId,
      fee: receipt.fee,
      createdAt: createdAt,
      completedAt: receipt.completedAt,
      rewardsDonation: receipt.rewardsDonation,
      roundUpDonation: receipt.roundUpDonation,
      oneTimeDonation: receipt.oneTimeDonation,
      totalDonation: receipt.totalDonation,
      fundraiserName: rewards?.fundraiserName ?? .empty,
      charityName: rewards?.charityName ?? .empty
    )
  }
  
  // TODO: Remove this when removing the old folder
  func transactionDateInLocalZone(includeYear: Bool = false) -> String {
    let dateFormat: LiquidityDateFormatter = includeYear ? .fullTransactionDate : .shortTransactionDate
    let dateToFormat = completedAt ?? createdAt
    return dateToFormat.parsingDateStringToNewFormat(toDateFormat: dateFormat) ?? .empty
  }
  
  var createdDateTime: String {
    completedAt?.parsingDateStringToNewFormat(toDateFormat: .transactionDateTime) ?? .empty
  }
  
  var completedDateTime: String {
    completedAt?.parsingDateStringToNewFormat(toDateFormat: .transactionDateTime) ?? createdDateTime
  }
  
  var createdDate: String {
    createdAt.parsingDateStringToNewFormat(toDateFormat: .monthDayYearAbbrev) ?? .empty
  }
  
  var createdTime: String {
    createdAt.parsingDateStringToNewFormat(toDateFormat: .timeStandard)?.lowercased() ?? .empty
  }
  
  var completedDate: String {
    completedAt?.parsingDateStringToNewFormat(toDateFormat: .monthDayYearAbbrev) ?? .empty
  }
  
  var completedTime: String {
    completedAt?.parsingDateStringToNewFormat(toDateFormat: .timeStandard)?.lowercased() ?? "–"
  }
  
  var createdAtDate: Date? {
    if let format = LiquidityDateFormatter.getDateFormat(from: createdAt),
       let date = format.parseToDate(from: createdAt) {
      return date
    }
    return nil
  }
  
  var statusColor: Color {
    if status == .declined {
      return Colors.red400.swiftUIColor
    }
    
    return Colors.textSecondary.swiftUIColor
  }
  
  var cryptoIconImage: Image? {
    guard let currency = currency,
          let type = AssetType(rawValue: currency),
          type != .usd
    else {
      return nil
    }
    
    return type.icon
  }
  
  // TODO: Remove this when removing the old folder
  var colorForType: Color {
    if status == .pending {
      return Colors.pending.swiftUIColor
    }
    switch type {
    case .rewardReferral,
        .rewardCashBack,
        .rewardCryptoBack,
        .rewardCryptoDosh,
        .deposit,
        .cryptoDeposit,
        .refund,
        .cryptoBuy,
        .cryptoBuyRefund:
      return Colors.green.swiftUIColor
    case .purchase,
        .unknown,
        .withdraw,
        .cryptoWithdraw,
        .cryptoSell,
        .rewardCashBackReverse,
        .rewardCryptoBackReverse,
        .rewardWithdrawal,
        .cryptoGasDeduction,
        .systemFee:
      return Colors.error.swiftUIColor
      //TODO: handle different donation detail view (Cashtab/rewardTab)
    case .donation where rewards == nil:
      return Colors.error.swiftUIColor
    case .donation:
      return Colors.green.swiftUIColor
    }
  }
  
  var isCryptoTransaction: Bool {
    switch type {
    case .cryptoBuy,
        .cryptoSell,
        .cryptoDeposit,
        .cryptoBuyRefund,
        .cryptoWithdraw,
        .cryptoGasDeduction,
        .rewardCryptoBack,
        .rewardCryptoDosh,
        .rewardCryptoBackReverse,
        .rewardWithdrawal,
        .deposit,
        .withdraw:
      return true
    default:
      return false
    }
  }
  
  var detailType: TransactionDetailType {
    switch type {
    case .deposit:
      return .deposit
    case .withdraw:
      return .withdraw
    case .cryptoBuy, .cryptoSell, .cryptoDeposit, .cryptoWithdraw:
      return .crypto
    case .systemFee, .cryptoGasDeduction:
      return .fee
    case .rewardCashBack, .rewardCashBackReverse:
      return .cashback
      //TODO: handle different donation detail view (Cashtab/rewardTab)
    case .donation where rewards == nil:
      return .cashback
    case .donation:
      return .donation
    case .refund, .cryptoBuyRefund:
      return .refund
    case .purchase:
      return .purchase
    case .rewardReferral, .rewardCryptoBack, .rewardCryptoDosh, .rewardWithdrawal:
      return .reward
    case .rewardCryptoBackReverse:
      return .rewardReversal
    default:
      return .common
    }
  }
  
  var estimateCompletedDate: String? {
    guard let format = LiquidityDateFormatter.getDateFormat(from: createdAt),
          let inputDate = format.parseToDate(from: createdAt),
          let twoDaysLaterDate = Calendar.current.date(byAdding: .day, value: 2, to: inputDate) else {
      return nil
    }
    return LiquidityDateFormatter.monthDayAbbrev.parseToString(from: twoDaysLaterDate)
  }
}

public extension TransactionModel {
  init(from transactionEntity: TransactionEntity) {
    self.init(
      id: transactionEntity.id,
      accountId: transactionEntity.accountId,
      title: transactionEntity.title,
      enrichedMerchantName: transactionEntity.enrichedMerchantName,
      enrichedMerchantIcon: transactionEntity.enrichedMerchantIcon,
      enrichedMerchantCategory: transactionEntity.enrichedMerchantCategory,
      currency: transactionEntity.currency,
      localCurrency: transactionEntity.localCurrency,
      description: transactionEntity.description,
      amount: abs(transactionEntity.amount),
      localAmount: transactionEntity.localAmount,
      currentBalance: transactionEntity.currentBalance,
      fee: transactionEntity.fee,
      type: TransactionType(rawValue: transactionEntity.type) ?? .unknown,
      status: TransactionStatus(rawValue: transactionEntity.status ?? .empty),
      completedAt: transactionEntity.completedAt,
      createdAt: transactionEntity.createdAt,
      updateAt: transactionEntity.updatedAt,
      contractAddress: transactionEntity.contractAddress,
      transactionHash: transactionEntity.transactionHash,
      note: Self.generateTransactionNote(noteEntity: transactionEntity.noteEnity),
      rewards: Self.generateTransactionReward(rewardEntity: transactionEntity.rewardEntity),
      receipt: Self.generateTransactionReceipt(receiptEntity: transactionEntity.receiptEntity),
      externalTransaction: Self.generateExternalTransaction(externalTransactionEntity: transactionEntity.externalTransactionEntity)
    )
  }
  
  static func generateTransactionNote(noteEntity: TransactionNoteEntity?) -> TransactionNote? {
    guard let noteEntity = noteEntity else {
      return nil
    }
    return TransactionNote(title: noteEntity.title, message: noteEntity.message)
  }
  
  static func generateTransactionReward(rewardEntity: RewardEntity?) -> TransactionReward? {
    guard let reward = rewardEntity else {
      return nil
    }
    return TransactionReward(
      status: TransactionStatus(rawValue: reward.status) ?? .unknown,
      type: RewardType(rawValue: reward.type ?? .empty) ?? .unknow,
      amount: reward.amount,
      stickerUrl: reward.stickerUrl,
      fundraiserName: reward.fundraiserName,
      charityName: reward.charityName,
      backgroundColor: reward.backgroundColor,
      description: reward.description
    )
  }
  
  static func generateExternalTransaction(externalTransactionEntity: ExternalTransactionEntity?) -> ExternalTransaction? {
    guard let externalTransaction = externalTransactionEntity else {
      return nil
    }
    return ExternalTransaction(
      type: externalTransaction.type,
      transactionType: externalTransaction.transactionType
    )
  }
  
  static func generateTransactionReceipt(receiptEntity: TransactionReceiptEntity?) -> TransactionReceipt? {
    guard let receipt = receiptEntity else {
      return nil
    }
    return TransactionReceipt(
      type: receipt.type,
      id: receipt.id,
      accountId: receipt.accountId,
      fee: receipt.fee,
      completedAt: receipt.completedAt,
      tradingPair: receipt.tradingPair,
      currency: receipt.currency,
      orderType: receipt.orderType,
      size: receipt.size,
      exchangeRate: receipt.exchangeRate,
      transactionValue: receipt.transactionValue,
      rewardsDonation: receipt.rewardsDonation,
      roundUpDonation: receipt.roundUpDonation,
      oneTimeDonation: receipt.oneTimeDonation,
      totalDonation: receipt.totalDonation
    )
  }
  
  static var `default` = TransactionModel(
    id: .empty,
    accountId: .empty,
    amount: 0,
    type: .unknown,
    createdAt: .empty,
    updateAt: .empty
  )
}

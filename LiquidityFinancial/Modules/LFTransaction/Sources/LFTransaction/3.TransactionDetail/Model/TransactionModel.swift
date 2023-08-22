import Foundation
import AccountDomain
import SwiftUI
import LFStyleGuide

public struct TransactionModel: Identifiable {
  public var id: String
  public var accountId: String
  public var title: String?
  public var description: String?
  public var amount: Double
  public var currentBalance: Double?
  public var fee: Double?
  public var type: TransactionType
  public var status: TransactionStatus?
  public var completedAt: String?
  public var createdAt: String
  public var updateAt: String
  var rewards: TransactionReward?
  var receipt: TransactionReceipt?
}

// MARK: - View Helpers
public extension TransactionModel {
  var titleDisplay: String {
    guard let title = title else { return descriptionDisplay }
    return title.isEmpty ? descriptionDisplay : title
  }
  
  var subtitle: String {
    if let status = status {
      return status == .pending ? status.localizedDescription() : transactionDateInLocalZone()
    }
    return TransactionStatus.unknown.localizedDescription()
  }
  
  var ammountFormatted: String {
    amount.formattedAmount(minFractionDigits: 3, maxFractionDigits: 3)
  }
  
  var balanceFormatted: String? {
    currentBalance?.formattedAmount(minFractionDigits: 3, maxFractionDigits: 3)
  }
  
  var descriptionDisplay: String {
    description ?? ""
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
  
  func transactionDateInLocalZone(includeYear: Bool = false) -> String {
    createdAt.serverToTransactionDisplay(includeYear: includeYear)
  }
  
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
        .cryptoBuyRefund,
        .donation:
      return Colors.green.swiftUIColor
    case .purchase,
        .unknown,
        .withdraw,
        .cryptoWidthDraw,
        .cryptoSell,
        .rewardCashBackReverse,
        .rewardCryptoBackReverse,
        .cryptoGasDeduction,
        .systemFee:
      return Colors.error.swiftUIColor
    }
  }
  
  var isCryptoTransaction: Bool {
    switch type {
    case .cryptoBuy,
        .cryptoSell,
        .cryptoDeposit,
        .cryptoBuyRefund,
        .cryptoWidthDraw,
        .rewardCryptoBack,
        .rewardCryptoDosh,
        .rewardCryptoBackReverse:
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
    case .cryptoBuy, .cryptoSell, .cryptoDeposit, .cryptoWidthDraw:
      return .crypto
    case .systemFee, .cryptoGasDeduction:
      return .fee
    case .rewardCashBack, .rewardCashBackReverse:
      return .cashback
    case .donation:
      return .donation
    case .refund, .cryptoBuyRefund:
      return .refund
    case .purchase:
      return .purchase
    case .rewardReferral, .rewardCryptoBack, .rewardCryptoDosh:
      return .reward
    case .rewardCryptoBackReverse:
      return .rewardReversal
    default:
      return .common
    }
  }
  
  var estimateCompletedDate: String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
    if let inputDate = dateFormatter.date(from: createdAt) {
      if let newDate = Calendar.current.date(byAdding: .day, value: 2, to: inputDate) {
        return DateFormatter.monthDayDisplay.string(from: newDate)
      }
      return nil
    }
    return nil
  }
}

extension TransactionModel: Equatable {
  public static func == (lhs: TransactionModel, rhs: TransactionModel) -> Bool {
    lhs.id == rhs.id
  }
}

public extension TransactionModel {
  init(from transactionEntity: TransactionEntity) {
    self.init(
      id: transactionEntity.id,
      accountId: transactionEntity.accountId,
      title: transactionEntity.title,
      description: transactionEntity.description,
      amount: transactionEntity.amount,
      currentBalance: transactionEntity.currentBalance,
      fee: transactionEntity.fee,
      type: TransactionType(rawValue: transactionEntity.type) ?? .unknown,
      status: TransactionStatus(rawValue: transactionEntity.status ?? .empty),
      completedAt: transactionEntity.completedAt,
      createdAt: transactionEntity.createdAt,
      updateAt: transactionEntity.updatedAt,
      rewards: Self.generateTransactionReward(rewardEntity: transactionEntity.rewardEntity),
      receipt: Self.generateTransactionReceipt(receiptEntity: transactionEntity.receiptEntity)
    )
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

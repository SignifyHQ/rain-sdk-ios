import Foundation

// sourcery: AutoMockable
public protocol TransactionListEntity {
  var total: Int { get }
  var data: [TransactionEntity] { get }
}

// sourcery: AutoMockable
public protocol TransactionEntity {
  var id: String { get }
  var accountId: String { get }
  var title: String? { get }
  var currency: String? { get }
  var description: String? { get }
  var amount: Double { get }
  var currentBalance: Double? { get }
  var fee: Double? { get }
  var type: String { get }
  var status: String? { get }
  var completedAt: String? { get }
  var createdAt: String { get }
  var updatedAt: String { get }
  var contractAddress: String? { get }
  var transactionHash: String? { get }
  var noteEnity: TransactionNoteEntity? { get }
  var rewardEntity: RewardEntity? { get }
  var receiptEntity: TransactionReceiptEntity? { get }
  var externalTransactionEntity: ExternalTransactionEntity? { get }
}

// sourcery: AutoMockable
public protocol ExternalTransactionEntity {
  var type: String? { get }
  var transactionType: String? { get }
  init(type: String?, transactionType: String?)
}

// sourcery: AutoMockable
public protocol RewardEntity {
  var status: String { get }
  var type: String? { get }
  var amount: Double? { get }
  var stickerUrl: String? { get }
  var backgroundColor: String? { get }
  var description: String? { get }
  var fundraiserName: String? { get }
  var charityName: String? { get }
  init(status: String, type: String?, amount: Double?, stickerUrl: String?, backgroundColor: String?, description: String?, fundraiserName: String?, charityName: String?)
}

// sourcery: AutoMockable
public protocol TransactionNoteEntity {
  var title: String? { get }
  var message: String? { get }
  init(title: String?, message: String?)
}

// sourcery: AutoMockable
public protocol TransactionReceiptEntity {
  var type: String { get }
  var id: String { get }
  var accountId: String { get }
  var fee: Double? { get }
  var completedAt: String? { get }
  var tradingPair: String? { get }
  var currency: String? { get }
  var orderType: String? { get }
  var size: Double? { get }
  var exchangeRate: Double? { get }
  var transactionValue: Double? { get }
  var rewardsDonation: Double? { get }
  var roundUpDonation: Double? { get }
  var oneTimeDonation: Double? { get }
  var totalDonation: Double? { get }
  init(type: String, id: String, accountId: String, fee: Double?, completedAt: String?, tradingPair: String?, currency: String?, orderType: String?, size: Double?, exchangeRate: Double?, transactionValue: Double?, rewardsDonation: Double?, roundUpDonation: Double?, oneTimeDonation: Double?, totalDonation: Double?)
}

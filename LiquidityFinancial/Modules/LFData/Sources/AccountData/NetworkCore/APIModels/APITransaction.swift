import Foundation
import AccountDomain

public struct APITransactionList: TransactionListEntity {
  public var total: Int
  public var data: [TransactionEntity]
  
  public init(total: Int, data: [TransactionEntity]) {
    self.total = total
    self.data = data
  }
}

public struct APITransaction: Codable, TransactionEntity {
  public let id: String
  public let accountId: String
  public let title: String?
  public let enrichedMerchantName: String?
  public let enrichedMerchantIcon: String?
  public let enrichedMerchantCategory: String?
  public var currency: String?
  public var localCurrency: String?
  public let description: String?
  public let amount: Double
  public let localAmount: Double?
  public let currentBalance: Double?
  public let fee: Double?
  public let type: String
  public let status: String?
  public let completedAt: String?
  public let createdAt: String
  public let updatedAt: String
  public let contractAddress: String?
  public let transactionHash: String?
  public var reward: APIReward?
  public var receipt: APITransactionReceipt?
  public var externalTransaction: APIExternalTransaction?
  public var note: APITransactionNote?
  
  public init(
    id: String,
    accountId: String,
    title: String?,
    enrichedMerchantName: String?,
    enrichedMerchantIcon: String?,
    enrichedMerchantCategory: String?,
    description: String?,
    amount: Double,
    localAmount: Double?,
    currentBalance: Double?,
    fee: Double?,
    type: String,
    status: String?,
    completedAt: String?,
    createdAt: String,
    updatedAt: String,
    contractAddress: String?,
    transactionHash: String?,
    reward: APIReward? = nil,
    receipt: APITransactionReceipt? = nil,
    externalTransaction: APIExternalTransaction? = nil,
    note: APITransactionNote? = nil
  ) {
    self.id = id
    self.accountId = accountId
    self.title = title
    self.enrichedMerchantName = enrichedMerchantName
    self.enrichedMerchantIcon = enrichedMerchantIcon
    self.enrichedMerchantCategory = enrichedMerchantCategory
    self.description = description
    self.amount = amount
    self.localAmount = localAmount
    self.currentBalance = currentBalance
    self.fee = fee
    self.type = type
    self.status = status
    self.completedAt = completedAt
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.contractAddress = contractAddress
    self.transactionHash = transactionHash
    self.reward = reward
    self.receipt = receipt
    self.externalTransaction = externalTransaction
    self.note = note
  }
}

extension APITransaction {
  public var externalTransactionEntity: ExternalTransactionEntity? {
    externalTransaction
  }
  
  public var rewardEntity: RewardEntity? {
    reward
  }
  
  public var receiptEntity: TransactionReceiptEntity? {
    receipt
  }
  
  public var noteEnity: TransactionNoteEntity? {
    note
  }
}

public struct APIExternalTransaction: Codable, ExternalTransactionEntity {
  public let type: String?
  public let transactionType: String?
  
  public init(type: String?, transactionType: String?) {
    self.type = type
    self.transactionType = transactionType
  }
}

public struct APIReward: Codable, RewardEntity {
  public let status: String
  public let type: String?
  public let amount: Double?
  public let stickerUrl: String?
  public let backgroundColor: String?
  public var description: String?
  public var fundraiserName: String?
  public var charityName: String?
  
  public init(status: String, type: String?, amount: Double?, stickerUrl: String?, backgroundColor: String?, description: String? = nil, fundraiserName: String? = nil, charityName: String? = nil) {
    self.status = status
    self.type = type
    self.amount = amount
    self.stickerUrl = stickerUrl
    self.backgroundColor = backgroundColor
    self.description = description
    self.fundraiserName = fundraiserName
    self.charityName = charityName
  }
}

public struct APITransactionReceipt: Codable, TransactionReceiptEntity {
  public let type: String
  public let id: String
  public let accountId: String
  public let fee: Double?
  public let completedAt: String?
  public let tradingPair: String?
  public let currency: String?
  public let orderType: String?
  public let size: Double?
  public let exchangeRate: Double?
  public let transactionValue: Double?
  public let rewardsDonation: Double?
  public let roundUpDonation: Double?
  public let oneTimeDonation: Double?
  public let totalDonation: Double?
  
  public init(type: String, id: String, accountId: String, fee: Double?, completedAt: String?, tradingPair: String?, currency: String?, orderType: String?, size: Double?, exchangeRate: Double?, transactionValue: Double?, rewardsDonation: Double?, roundUpDonation: Double?, oneTimeDonation: Double?, totalDonation: Double?) {
    self.type = type
    self.id = id
    self.accountId = accountId
    self.fee = fee
    self.completedAt = completedAt
    self.tradingPair = tradingPair
    self.currency = currency
    self.orderType = orderType
    self.size = size
    self.exchangeRate = exchangeRate
    self.transactionValue = transactionValue
    self.rewardsDonation = rewardsDonation
    self.roundUpDonation = roundUpDonation
    self.oneTimeDonation = oneTimeDonation
    self.totalDonation = totalDonation
  }
}

public struct APITransactionNote: Codable, TransactionNoteEntity {
  public let title: String?
  public let message: String?
  
  public init(title: String?, message: String?) {
    self.title = title
    self.message = message
  }
}

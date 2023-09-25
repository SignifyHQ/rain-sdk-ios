import Foundation
import AccountDomain

public struct APITransactionList: TransactionListEntity {
  public var total: Int
  public var data: [TransactionEntity]
}

public struct APITransaction: Codable {
  public let id: String
  public let accountId: String
  public let title: String?
  public let description: String?
  public let amount: Double
  public let currentBalance: Double?
  public let fee: Double?
  public let type: String
  public let status: String?
  public let completedAt: String?
  public let createdAt: String
  public let updatedAt: String
  public var reward: APIReward?
  public var receipt: APITransactionReceipt?
  public var externalTransaction: APIExternalTransaction?
  public var note: APITransactionNote?
}

extension APITransaction: TransactionEntity {
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
}

public struct APITransactionNote: Codable, TransactionNoteEntity {
  public let title: String?
  public let message: String?
}

// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain

public class MockTransactionEntity: TransactionEntity {

    public init() {}

    public var id: String {
        get { return underlyingId }
        set(value) { underlyingId = value }
    }
    public var underlyingId: String!
    public var accountId: String {
        get { return underlyingAccountId }
        set(value) { underlyingAccountId = value }
    }
    public var underlyingAccountId: String!
    public var title: String?
    public var description: String?
    public var amount: Double {
        get { return underlyingAmount }
        set(value) { underlyingAmount = value }
    }
    public var underlyingAmount: Double!
    public var currentBalance: Double?
    public var fee: Double?
    public var type: String {
        get { return underlyingType }
        set(value) { underlyingType = value }
    }
    public var underlyingType: String!
    public var status: String?
    public var completedAt: String?
    public var createdAt: String {
        get { return underlyingCreatedAt }
        set(value) { underlyingCreatedAt = value }
    }
    public var underlyingCreatedAt: String!
    public var updatedAt: String {
        get { return underlyingUpdatedAt }
        set(value) { underlyingUpdatedAt = value }
    }
    public var underlyingUpdatedAt: String!
    public var noteEnity: TransactionNoteEntity?
    public var rewardEntity: RewardEntity?
    public var receiptEntity: TransactionReceiptEntity?
    public var externalTransactionEntity: ExternalTransactionEntity?

    //MARK: - init

    public var initIdAccountIdTitleDescriptionAmountCurrentBalanceFeeTypeStatusCompletedAtCreatedAtUpdatedAtRewardReceiptExternalTransactionNoteReceivedArguments: (id: String, accountId: String, title: String?, description: String?, amount: Double, currentBalance: Double?, fee: Double?, type: String, status: String?, completedAt: String?, createdAt: String, updatedAt: String, reward: RewardEntity?, receipt: TransactionReceiptEntity?, externalTransaction: ExternalTransactionEntity?, note: TransactionNoteEntity?)?
    public var initIdAccountIdTitleDescriptionAmountCurrentBalanceFeeTypeStatusCompletedAtCreatedAtUpdatedAtRewardReceiptExternalTransactionNoteReceivedInvocations: [(id: String, accountId: String, title: String?, description: String?, amount: Double, currentBalance: Double?, fee: Double?, type: String, status: String?, completedAt: String?, createdAt: String, updatedAt: String, reward: RewardEntity?, receipt: TransactionReceiptEntity?, externalTransaction: ExternalTransactionEntity?, note: TransactionNoteEntity?)] = []
    public var initIdAccountIdTitleDescriptionAmountCurrentBalanceFeeTypeStatusCompletedAtCreatedAtUpdatedAtRewardReceiptExternalTransactionNoteClosure: ((String, String, String?, String?, Double, Double?, Double?, String, String?, String?, String, String, RewardEntity?, TransactionReceiptEntity?, ExternalTransactionEntity?, TransactionNoteEntity?) -> Void)?

    public required init(id: String, accountId: String, title: String?, description: String?, amount: Double, currentBalance: Double?, fee: Double?, type: String, status: String?, completedAt: String?, createdAt: String, updatedAt: String, reward: RewardEntity?, receipt: TransactionReceiptEntity?, externalTransaction: ExternalTransactionEntity?, note: TransactionNoteEntity?) {
        initIdAccountIdTitleDescriptionAmountCurrentBalanceFeeTypeStatusCompletedAtCreatedAtUpdatedAtRewardReceiptExternalTransactionNoteReceivedArguments = (id: id, accountId: accountId, title: title, description: description, amount: amount, currentBalance: currentBalance, fee: fee, type: type, status: status, completedAt: completedAt, createdAt: createdAt, updatedAt: updatedAt, reward: reward, receipt: receipt, externalTransaction: externalTransaction, note: note)
        initIdAccountIdTitleDescriptionAmountCurrentBalanceFeeTypeStatusCompletedAtCreatedAtUpdatedAtRewardReceiptExternalTransactionNoteReceivedInvocations.append((id: id, accountId: accountId, title: title, description: description, amount: amount, currentBalance: currentBalance, fee: fee, type: type, status: status, completedAt: completedAt, createdAt: createdAt, updatedAt: updatedAt, reward: reward, receipt: receipt, externalTransaction: externalTransaction, note: note))
        initIdAccountIdTitleDescriptionAmountCurrentBalanceFeeTypeStatusCompletedAtCreatedAtUpdatedAtRewardReceiptExternalTransactionNoteClosure?(id, accountId, title, description, amount, currentBalance, fee, type, status, completedAt, createdAt, updatedAt, reward, receipt, externalTransaction, note)
    }
}

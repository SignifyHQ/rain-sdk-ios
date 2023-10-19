// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain

public class MockTransactionListEntity: TransactionListEntity {

    public init() {}

    public var total: Int {
        get { return underlyingTotal }
        set(value) { underlyingTotal = value }
    }
    public var underlyingTotal: Int!
    public var data: [TransactionEntity] = []

    //MARK: - init

    public var initTotalDataReceivedArguments: (total: Int, data: [TransactionEntity])?
    public var initTotalDataReceivedInvocations: [(total: Int, data: [TransactionEntity])] = []
    public var initTotalDataClosure: ((Int, [TransactionEntity]) -> Void)?

    public required init(total: Int, data: [TransactionEntity]) {
        initTotalDataReceivedArguments = (total: total, data: data)
        initTotalDataReceivedInvocations.append((total: total, data: data))
        initTotalDataClosure?(total, data)
    }
}

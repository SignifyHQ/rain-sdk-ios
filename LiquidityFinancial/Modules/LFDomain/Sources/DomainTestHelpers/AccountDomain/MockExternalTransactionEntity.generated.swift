// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain

public class MockExternalTransactionEntity: ExternalTransactionEntity {

    public init() {}

    public var type: String?
    public var transactionType: String?

    //MARK: - init

    public var initTypeTransactionTypeReceivedArguments: (type: String?, transactionType: String?)?
    public var initTypeTransactionTypeReceivedInvocations: [(type: String?, transactionType: String?)] = []
    public var initTypeTransactionTypeClosure: ((String?, String?) -> Void)?

    public required init(type: String?, transactionType: String?) {
        initTypeTransactionTypeReceivedArguments = (type: type, transactionType: transactionType)
        initTypeTransactionTypeReceivedInvocations.append((type: type, transactionType: transactionType))
        initTypeTransactionTypeClosure?(type, transactionType)
    }
}

// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain

public class MockTransactionNoteEntity: TransactionNoteEntity {

    public init() {}

    public var title: String?
    public var message: String?

    //MARK: - init

    public var initTitleMessageReceivedArguments: (title: String?, message: String?)?
    public var initTitleMessageReceivedInvocations: [(title: String?, message: String?)] = []
    public var initTitleMessageClosure: ((String?, String?) -> Void)?

    public required init(title: String?, message: String?) {
        initTitleMessageReceivedArguments = (title: title, message: message)
        initTitleMessageReceivedInvocations.append((title: title, message: message))
        initTitleMessageClosure?(title, message)
    }
}

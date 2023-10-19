// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain

public class MockWalletAddressEntity: WalletAddressEntity {

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
    public var nickname: String?
    public var address: String {
        get { return underlyingAddress }
        set(value) { underlyingAddress = value }
    }
    public var underlyingAddress: String!

    //MARK: - init

    public var initIdAccountIdNicknameAddressReceivedArguments: (id: String, accountId: String, nickname: String?, address: String)?
    public var initIdAccountIdNicknameAddressReceivedInvocations: [(id: String, accountId: String, nickname: String?, address: String)] = []
    public var initIdAccountIdNicknameAddressClosure: ((String, String, String?, String) -> Void)?

    public required init(id: String, accountId: String, nickname: String?, address: String) {
        initIdAccountIdNicknameAddressReceivedArguments = (id: id, accountId: accountId, nickname: nickname, address: address)
        initIdAccountIdNicknameAddressReceivedInvocations.append((id: id, accountId: accountId, nickname: nickname, address: address))
        initIdAccountIdNicknameAddressClosure?(id, accountId, nickname, address)
    }
}

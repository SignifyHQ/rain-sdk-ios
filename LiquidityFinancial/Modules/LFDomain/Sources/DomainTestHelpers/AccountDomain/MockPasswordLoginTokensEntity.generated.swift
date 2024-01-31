// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AccountDomain

public class MockPasswordLoginTokensEntity: PasswordLoginTokensEntity {

    public init() {}

    public var accessToken: String {
        get { return underlyingAccessToken }
        set(value) { underlyingAccessToken = value }
    }
    public var underlyingAccessToken: String!
    public var refreshToken: String {
        get { return underlyingRefreshToken }
        set(value) { underlyingRefreshToken = value }
    }
    public var underlyingRefreshToken: String!
    public var expiresIn: String {
        get { return underlyingExpiresIn }
        set(value) { underlyingExpiresIn = value }
    }
    public var underlyingExpiresIn: String!

}

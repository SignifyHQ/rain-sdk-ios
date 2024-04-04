// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import OnboardingDomain

public class MockAccessTokensEntity: AccessTokensEntity {

    public init() {}

    public var accessToken: String {
        get { return underlyingAccessToken }
        set(value) { underlyingAccessToken = value }
    }
    public var underlyingAccessToken: String!
    public var tokenType: String {
        get { return underlyingTokenType }
        set(value) { underlyingTokenType = value }
    }
    public var underlyingTokenType: String!
    public var refreshToken: String {
        get { return underlyingRefreshToken }
        set(value) { underlyingRefreshToken = value }
    }
    public var underlyingRefreshToken: String!
    public var expiresIn: Int {
        get { return underlyingExpiresIn }
        set(value) { underlyingExpiresIn = value }
    }
    public var underlyingExpiresIn: Int!
    public var expiresAt: Date {
        get { return underlyingExpiresAt }
        set(value) { underlyingExpiresAt = value }
    }
    public var underlyingExpiresAt: Date!
    public var bearerAccessToken: String {
        get { return underlyingBearerAccessToken }
        set(value) { underlyingBearerAccessToken = value }
    }
    public var underlyingBearerAccessToken: String!
    public var portalSessionToken: String?

    //MARK: - init

    public var initAccessTokenTokenTypeRefreshTokenPortalSessionTokenExpiresInReceivedArguments: (accessToken: String, tokenType: String, refreshToken: String, portalSessionToken: String?, expiresIn: Int)?
    public var initAccessTokenTokenTypeRefreshTokenPortalSessionTokenExpiresInReceivedInvocations: [(accessToken: String, tokenType: String, refreshToken: String, portalSessionToken: String?, expiresIn: Int)] = []
    public var initAccessTokenTokenTypeRefreshTokenPortalSessionTokenExpiresInClosure: ((String, String, String, String?, Int) -> Void)?

    public required init(accessToken: String, tokenType: String, refreshToken: String, portalSessionToken: String?, expiresIn: Int) {
        initAccessTokenTokenTypeRefreshTokenPortalSessionTokenExpiresInReceivedArguments = (accessToken: accessToken, tokenType: tokenType, refreshToken: refreshToken, portalSessionToken: portalSessionToken, expiresIn: expiresIn)
        initAccessTokenTokenTypeRefreshTokenPortalSessionTokenExpiresInReceivedInvocations.append((accessToken: accessToken, tokenType: tokenType, refreshToken: refreshToken, portalSessionToken: portalSessionToken, expiresIn: expiresIn))
        initAccessTokenTokenTypeRefreshTokenPortalSessionTokenExpiresInClosure?(accessToken, tokenType, refreshToken, portalSessionToken, expiresIn)
    }
}

// Generated using Sourcery 2.0.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import Foundation
import AuthorizationManager
import OnboardingDomain

public class MockAuthorizationManagerProtocol: AuthorizationManagerProtocol {

    public init() {}

    public var logOutForcedName: Notification.Name {
        get { return underlyingLogOutForcedName }
        set(value) { underlyingLogOutForcedName = value }
    }
    public var underlyingLogOutForcedName: Notification.Name!

    //MARK: - isTokenValid

    public var isTokenValidCallsCount = 0
    public var isTokenValidCalled: Bool {
        return isTokenValidCallsCount > 0
    }
    public var isTokenValidReturnValue: Bool!
    public var isTokenValidClosure: (() -> Bool)?

    public func isTokenValid() -> Bool {
        isTokenValidCallsCount += 1
        if let isTokenValidClosure = isTokenValidClosure {
            return isTokenValidClosure()
        } else {
            return isTokenValidReturnValue
        }
    }

    //MARK: - fetchAccessToken

    public var fetchAccessTokenCallsCount = 0
    public var fetchAccessTokenCalled: Bool {
        return fetchAccessTokenCallsCount > 0
    }
    public var fetchAccessTokenReturnValue: String!
    public var fetchAccessTokenClosure: (() -> String)?

    public func fetchAccessToken() -> String {
        fetchAccessTokenCallsCount += 1
        if let fetchAccessTokenClosure = fetchAccessTokenClosure {
            return fetchAccessTokenClosure()
        } else {
            return fetchAccessTokenReturnValue
        }
    }

    //MARK: - fetchRefreshToken

    public var fetchRefreshTokenCallsCount = 0
    public var fetchRefreshTokenCalled: Bool {
        return fetchRefreshTokenCallsCount > 0
    }
    public var fetchRefreshTokenReturnValue: String!
    public var fetchRefreshTokenClosure: (() -> String)?

    public func fetchRefreshToken() -> String {
        fetchRefreshTokenCallsCount += 1
        if let fetchRefreshTokenClosure = fetchRefreshTokenClosure {
            return fetchRefreshTokenClosure()
        } else {
            return fetchRefreshTokenReturnValue
        }
    }

    //MARK: - refreshWith

    public var refreshWithApiTokenCallsCount = 0
    public var refreshWithApiTokenCalled: Bool {
        return refreshWithApiTokenCallsCount > 0
    }
    public var refreshWithApiTokenReceivedApiToken: AccessTokensEntity?
    public var refreshWithApiTokenReceivedInvocations: [AccessTokensEntity] = []
    public var refreshWithApiTokenClosure: ((AccessTokensEntity) -> Void)?

    public func refreshWith(apiToken: AccessTokensEntity) {
        refreshWithApiTokenCallsCount += 1
        refreshWithApiTokenReceivedApiToken = apiToken
        refreshWithApiTokenReceivedInvocations.append(apiToken)
        refreshWithApiTokenClosure?(apiToken)
    }

    //MARK: - refreshToken

    public var refreshTokenThrowableError: Error?
    public var refreshTokenCallsCount = 0
    public var refreshTokenCalled: Bool {
        return refreshTokenCallsCount > 0
    }
    public var refreshTokenClosure: (() async throws -> Void)?

    public func refreshToken() async throws {
        if let error = refreshTokenThrowableError {
            throw error
        }
        refreshTokenCallsCount += 1
        try await refreshTokenClosure?()
    }

    //MARK: - clearToken

    public var clearTokenCallsCount = 0
    public var clearTokenCalled: Bool {
        return clearTokenCallsCount > 0
    }
    public var clearTokenClosure: (() -> Void)?

    public func clearToken() {
        clearTokenCallsCount += 1
        clearTokenClosure?()
    }

    //MARK: - update

    public var updateCallsCount = 0
    public var updateCalled: Bool {
        return updateCallsCount > 0
    }
    public var updateClosure: (() -> Void)?

    public func update() {
        updateCallsCount += 1
        updateClosure?()
    }

    //MARK: - forcedLogout

    public var forcedLogoutCallsCount = 0
    public var forcedLogoutCalled: Bool {
        return forcedLogoutCallsCount > 0
    }
    public var forcedLogoutClosure: (() -> Void)?

    public func forcedLogout() {
        forcedLogoutCallsCount += 1
        forcedLogoutClosure?()
    }

    //MARK: - refresh

    public var refreshWithCompletionCallsCount = 0
    public var refreshWithCompletionCalled: Bool {
        return refreshWithCompletionCallsCount > 0
    }
    public var refreshWithCompletionReceivedArguments: (accessTokens: OAuthCredential, completion: (Result<OAuthCredential, Error>) -> Void)?
    public var refreshWithCompletionReceivedInvocations: [(accessTokens: OAuthCredential, completion: (Result<OAuthCredential, Error>) -> Void)] = []
    public var refreshWithCompletionClosure: ((OAuthCredential, @escaping (Result<OAuthCredential, Error>) -> Void) -> Void)?

    public func refresh(with accessTokens: OAuthCredential, completion: @escaping (Result<OAuthCredential, Error>) -> Void) {
        refreshWithCompletionCallsCount += 1
        refreshWithCompletionReceivedArguments = (accessTokens: accessTokens, completion: completion)
        refreshWithCompletionReceivedInvocations.append((accessTokens: accessTokens, completion: completion))
        refreshWithCompletionClosure?(accessTokens, completion)
    }

    //MARK: - fetchTokens

    public var fetchTokensCallsCount = 0
    public var fetchTokensCalled: Bool {
        return fetchTokensCallsCount > 0
    }
    public var fetchTokensReturnValue: OAuthCredential?
    public var fetchTokensClosure: (() -> OAuthCredential?)?

    public func fetchTokens() -> OAuthCredential? {
        fetchTokensCallsCount += 1
        if let fetchTokensClosure = fetchTokensClosure {
            return fetchTokensClosure()
        } else {
            return fetchTokensReturnValue
        }
    }

}

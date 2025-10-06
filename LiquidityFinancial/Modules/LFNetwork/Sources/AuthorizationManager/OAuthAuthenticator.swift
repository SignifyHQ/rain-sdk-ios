import Alamofire
import Foundation
import LFUtilities

// swiftlint:disable all

public protocol AuthenticatorDelegate: AnyObject {
  func requestTokens(
    with tokens: OAuthCredential,
    completion: @escaping (Result<OAuthCredential, Error>) -> Void
  )
}

public final class OAuthAuthenticator: Authenticator, @unchecked Sendable {
  public init() {}
  
  public weak var delegate: AuthenticatorDelegate?
  
  public func apply(
    _ credential: OAuthCredential,
    to urlRequest: inout URLRequest
  ) {
    urlRequest.headers.add(authHeader(credential: credential))
  }
  
  public func refresh(
    _ credential: OAuthCredential,
    for _: Session,
    completion: @escaping (Result<OAuthCredential, Error>) -> Void
  ) {
    guard let delegate = delegate
    else {
      log.error("Authenticator. Token refresh failed: no AuthenticatorDelegate assigned.")
      completion(.failure(AuthError.noTokenProvider))
      
      return
    }
    
    log.info("Authenticator. Refreshing tokens using delegate...")
    delegate.requestTokens(
      with: credential
    ) { result in
      switch result {
      case .success(let newCredential):
        log.info("Authenticator. Token refresh successful. New access token obtained.")
        completion(.success(newCredential))
      case .failure(let error):
        log.error("Authenticator. Token refresh failed with error: \(error.localizedDescription)")
        completion(.failure(error))
      }
    }
  }
  
  public func didRequest(
    _: URLRequest,
    with response: HTTPURLResponse,
    failDueToAuthenticationError _: Error
  ) -> Bool {
    let isAuthError = response.statusCode == 401
    
    if isAuthError {
      log.info("Authenticator. Authentication failed with 401. Token refresh will be attempted.")
    } else {
      log.debug("Authenticator. Received HTTP \(response.statusCode). Not an authentication error.")
    }
    
    return isAuthError
  }
  
  public func isRequest(
    _ urlRequest: URLRequest,
    authenticatedWith credential: OAuthCredential
  ) -> Bool {
    // If authentication server CAN invalidate credentials, then compare the "Authorization" header value in the
    // `URLRequest` against the Bearer token generated with the access token of the `Credential`.
    
    let isAuthenticated = urlRequest.headers["Authorization"] == authHeader(credential: credential).value
    log.debug("Authenticator. Checked if request is authenticated: \(isAuthenticated)")
    
    return isAuthenticated
  }
}

// Private helpers
extension OAuthAuthenticator {
  private func authHeader(
    credential: OAuthCredential
  ) -> HTTPHeader {
    .authorization(bearerToken: credential.accessToken)
  }
  
  private enum AuthError: Error {
    case noTokenProvider
  }
}

import Alamofire
import Factory
import Foundation
import LFUtilities

// swiftlint:disable all

public final class DefaultAuthenticator: Authenticator, @unchecked Sendable {
  @LazyInjected(\.authorizationManager) var authorizationManager
  
  public init() {}
  
  private let refreshQueue = DispatchQueue(label: "com.myapp.oauth-refresh")
  private var isRefreshing = false
  private var pendingCompletions: [(Result<AuthCredential, Error>) -> Void] = []
  
  public func apply(
    _ credential: AuthCredential,
    to urlRequest: inout URLRequest
  ) {
    urlRequest.headers.add(authHeader(credential: credential))
  }
  
  public func refresh(
    _ credential: AuthCredential,
    for _: Session,
    completion: @escaping (Result<AuthCredential, Error>) -> Void
  ) {
    refreshQueue
      .async { [weak self] in
        guard let self = self
        else {
          return
        }
        
        self.pendingCompletions.append(completion)
        
        if self.isRefreshing {
          log.info("Authenticator. Token refresh already in progress.")
          
          return
        }
        
        self.isRefreshing = true
        
        log.info("Authenticator. Starting token refresh...")
        authorizationManager.refresh(
          with: credential
        ) { result in
          self.refreshQueue.async {
            log.info("Authenticator. Token refresh completed. Calling \(self.pendingCompletions.count) pending completion(s).")
            
            self.pendingCompletions.forEach { $0(result) }
            self.pendingCompletions.removeAll()
            self.isRefreshing = false
          }
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
    authenticatedWith credential: AuthCredential
  ) -> Bool {
    // If authentication server CAN invalidate credentials, then compare the "Authorization" header value in the
    // `URLRequest` against the Bearer token generated with the access token of the `Credential`.
    
    let isAuthenticated = urlRequest.headers["Authorization"] == authHeader(credential: credential).value
    log.debug("Authenticator. Checked if request is authenticated: \(isAuthenticated)")
    
    return isAuthenticated
  }
}

// Private helpers
extension DefaultAuthenticator {
  private func authHeader(
    credential: AuthCredential
  ) -> HTTPHeader {
    .authorization(bearerToken: credential.accessToken)
  }
  
  private enum AuthError: Error {
    case noTokenProvider
  }
}

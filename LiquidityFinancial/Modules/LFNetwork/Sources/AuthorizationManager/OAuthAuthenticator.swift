import Alamofire
import Foundation

// swiftlint:disable all

public protocol AuthenticatorDelegate: AnyObject {
  func requestTokens(with tokens: OAuthCredential, completion: @escaping (Result<OAuthCredential, Error>) -> Void)
}

public class OAuthAuthenticator: Authenticator {
  public init() {}
  
  public weak var delegate: AuthenticatorDelegate?
  
  public static func authHeader(credential: OAuthCredential) -> HTTPHeader {
    .authorization(bearerToken: credential.accessToken)
  }
  
  public func apply(_ credential: OAuthCredential, to urlRequest: inout URLRequest) {
    urlRequest.headers.add(OAuthAuthenticator.authHeader(credential: credential))
  }
  
  public func refresh(_ credential: OAuthCredential,
                      for _: Session,
                      completion: @escaping (Result<OAuthCredential, Error>) -> Void) {
    guard let delegate = delegate else {
      completion(.failure(AuthError.noTokenProvider))
      return
    }
    
    delegate.requestTokens(with: credential, completion: completion)
  }
  
  public func didRequest(_: URLRequest,
                         with response: HTTPURLResponse,
                         failDueToAuthenticationError _: Error) -> Bool {
    response.statusCode == 401
  }
  
  public func isRequest(_ urlRequest: URLRequest, authenticatedWith credential: OAuthCredential) -> Bool {
      // If authentication server CAN invalidate credentials, then compare the "Authorization" header value in the
      // `URLRequest` against the Bearer token generated with the access token of the `Credential`.
    urlRequest.headers["Authorization"] == OAuthAuthenticator.authHeader(credential: credential).value
  }
  
  private enum AuthError: Error {
    case noTokenProvider
  }
}

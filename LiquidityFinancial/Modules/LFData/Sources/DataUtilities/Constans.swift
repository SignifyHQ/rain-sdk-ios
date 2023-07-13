import Foundation

// swiftlint:disable all
public enum APIConstants {
  public static let host = "api-crypto.dev.liquidity.cc"
  public static let port = 8080
  public static let scheme = "https"
  public static let grantType = "client_credentials"
  public static let clientId = "YourKeyHere"
  public static let clientSecret = "YourSecretHere"
  
  public static var baseURL: URL {
    .init(string: APIConstants.host)!
  }
  
}

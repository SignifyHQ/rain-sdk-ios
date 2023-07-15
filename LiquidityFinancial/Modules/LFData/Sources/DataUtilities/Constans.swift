import Foundation

// swiftlint:disable all
public enum APIConstants {
  public static let host = "https://api-crypto.dev.liquidity.cc"
  
  public static var baseURL: URL {
    .init(string: APIConstants.host)!
  }
  
  public static let productNameDefault = "DogeCard" //TODO: Update later when BE refactor done
  
}

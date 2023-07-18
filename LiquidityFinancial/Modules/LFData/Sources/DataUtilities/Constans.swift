import Foundation

// swiftlint:disable all
public enum APIConstants {
  public static let host = "https://api-crypto.dev.liquidity.cc"
  public static let productID = "fb352b08-c759-4a6c-8a63-d9d190265447"
  public static var baseURL: URL {
    .init(string: APIConstants.host)!
  }
  
  public static let productNameDefault = "DogeCard" //TODO: Update later when BE refactor done
  
}

import Foundation

// swiftlint:disable all
public enum APIConstants {
  public static let host = "https://api-crypto.dev.liquidity.cc"
  public static let avalencheID = "fb352b08-c759-4a6c-8a63-d9d190265447"
  public static let cardanoID = "3d126fa0-29d2-11ee-be56-0242ac120002"
  public static var baseURL: URL {
    .init(string: APIConstants.host)!
  }
  
}

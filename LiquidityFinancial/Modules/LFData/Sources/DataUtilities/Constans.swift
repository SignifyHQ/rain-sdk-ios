import Foundation

// swiftlint:disable all
public enum APIConstants {
  public static let host = "https://api-crypto.dev.liquidity.cc"
  public static let avalencheID = "fb352b08-c759-4a6c-8a63-d9d190265447"
  public static let cardanoID = "3d126fa0-29d2-11ee-be56-0242ac120002"
  public static let dogeCard = "1d77cffe-658a-4745-89b8-28997ab73ffc"
  public static let causeCard = "86cca907-8cb5-4bdf-99b3-d21811dc3038"
  public static let prideCard = "11c4c6d2-cafd-407f-a922-23a8b0580b21"
  public static var baseURL: URL {
    .init(string: APIConstants.host)!
  }
  
}


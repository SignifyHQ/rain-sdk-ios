import Foundation

// swiftlint:disable all
public enum APIConstants {
  public static let devHost = "https://api-crypto.dev.liquidity.cc"
  public static let avalencheID = "fb352b08-c759-4a6c-8a63-d9d190265447"
  public static let cardanoID = "3d126fa0-29d2-11ee-be56-0242ac120002"
  public static let dogeCardID = "1d77cffe-658a-4745-89b8-28997ab73ffc"
  public static let causeCardID = "86cca907-8cb5-4bdf-99b3-d21811dc3038"
  public static let prideCardID = "11c4c6d2-cafd-407f-a922-23a8b0580b21"
  public static var baseDevURL: URL {
    .init(string: APIConstants.devHost)!
  }
  
  public struct StatusCodes {
    public static let badRequest = 400
    public static let unauthorized = 401
    public static let forbidden = 403
    public static let notFound = 404
    public static let tooManyRequests = 429
    public static let gatewayTimeout = 504
    public static let notModified = 304
  }
}


import Foundation

// swiftlint:disable all
public enum APIConstants {
  public static let devHost = "https://service-platform.dev.liquidity-financial.com"
  public static let socketDevHost = "wss://service-platform.dev.liquidity-financial.com"
  public static let prodHost = "https://api-crypto.liquidity.cc"
  public static let socketProdHost = "wss://api-crypto.liquidity.cc"
  
  public static let avalencheID = "fb352b08-c759-4a6c-8a63-d9d190265447"
  public static let cardanoID = "3d126fa0-29d2-11ee-be56-0242ac120002"
  public static let dogeCardID = "9827b8f0-7be4-47b7-871b-99be386f49d4"
  public static let causeCardID = "7f2c1a97-e378-431c-98fa-76a61b03b38b"
  public static let prideCardID = "5ab62fe1-4d21-40c0-b50f-f8ab975ef87c"
  public static let pawsCardID = "323993bf-b8e0-4872-9968-90774663fbf9"
  
  public static var baseDevURL: URL {
    .init(string: APIConstants.devHost)!
  }
  public static var baseProdURL: URL {
    .init(string: APIConstants.prodHost)!
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


import Foundation

public struct NetSpendLinkedSourceData: Codable {
  public var bankName: String?
  public var name: String?
  public var last4: String
  public var sourceType: NetSpendSourceType
  public var sourceId: String
}

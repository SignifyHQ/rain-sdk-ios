import Foundation

public struct LinkedSourceContact {
  public var name: String?
  public var last4: String
  public var sourceType: LinkedSourceContactType
  public var sourceId: String
  
  public init(name: String? = nil, last4: String, sourceType: LinkedSourceContactType, sourceId: String) {
    self.name = name
    self.last4 = last4
    self.sourceType = sourceType
    self.sourceId = sourceId
  }
}

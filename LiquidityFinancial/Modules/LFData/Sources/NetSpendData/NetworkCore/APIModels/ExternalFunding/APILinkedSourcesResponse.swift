import Foundation
import NetSpendDomain

public struct APILinkedSourcesResponse: Codable, LinkedSourcesEntity {
  public typealias SourceData = APILinkedSourceData
  public var linkedSources: [SourceData]
  
  public init(linkedSources: [SourceData]) {
    self.linkedSources = linkedSources
  }
}

public struct APILinkedSourceData: Codable, LinkedSourceDataEntity {
  public var name: String?
  public var last4: String
  public var sourceType: APILinkSourceType
  public var sourceId: String
  
  public init?(name: String?, last4: String, sourceType: APILinkSourceType?, sourceId: String) {
    guard let sourceType = sourceType else { return nil }
    self.name = name
    self.last4 = last4
    self.sourceType = sourceType
    self.sourceId = sourceId
  }
}

public enum APILinkSourceType: String, Codable, LinkedSourceTypeEntity {
  public var rawString: String {
    self.rawValue
  }
  
  case externalBank = "EXTERNAL_BANK"
  case externalCard = "EXTERNAL_CARD"
  
}

import Foundation
import NetSpendDomain

public struct APILinkedSourcesResponse: Decodable, LinkedSourcesEntity {
  public typealias SourceData = APILinkedSourceData
  public var linkedSources: [SourceData]
  
  public init(linkedSources: [SourceData]) {
    self.linkedSources = linkedSources
  }
}

public struct APILinkedSourceData: Decodable, LinkedSourceDataEntity {
  public var bankName: String?
  public var name: String?
  public var last4: String
  public var sourceType: APILinkSourceType
  public var sourceId: String
  
  public init?(bankName: String? = nil, name: String? = nil, last4: String, sourceType: APILinkSourceType?, sourceId: String) {
    guard let sourceType = sourceType else { return nil }
    self.bankName = bankName
    self.name = name
    self.last4 = last4
    self.sourceType = sourceType
    self.sourceId = sourceId
  }
}

public enum APILinkSourceType: String, Decodable, LinkedSourceTypeEntity {
  public var rawString: String {
    self.rawValue
  }
  
  case externalBank = "EXTERNAL_BANK"
  case externalCard = "EXTERNAL_CARD"
  
}


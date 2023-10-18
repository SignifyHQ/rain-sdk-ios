import Foundation
import BankDomain

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
  public var requiredFlow: String?
  
  public init?(name: String?, last4: String, sourceType: APILinkSourceType?, sourceId: String, requiredFlow: String?) {
    guard let sourceType = sourceType else { return nil }
    self.name = name
    self.last4 = last4
    self.sourceType = sourceType
    self.sourceId = sourceId
    self.requiredFlow = requiredFlow
  }
  
  public init?(entity: any LinkedSourceDataEntity) {
    guard let sourceType = APILinkSourceType(rawValue: entity.sourceType.rawString) else {
      return nil
    }
    self.name = entity.name
    self.last4 = entity.last4
    self.sourceType = sourceType
    self.sourceId = entity.sourceId
    self.requiredFlow = entity.requiredFlow
  }
}

public enum APILinkSourceType: String, Codable, LinkedSourceTypeEntity {
  public var rawString: String {
    self.rawValue
  }
  
  case externalBank = "EXTERNAL_BANK"
  case externalCard = "EXTERNAL_CARD"
  
}

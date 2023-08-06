import Foundation

public protocol LinkedSourcesEntity {
  associatedtype APILinkedSourceDataEntity: LinkedSourceDataEntity
  var linkedSources: [APILinkedSourceDataEntity] { get }
}

public protocol LinkedSourceDataEntity {
  associatedtype APILinkedSourceTypeEntity: LinkedSourceTypeEntity
  var bankName: String? { get }
  var name: String? { get }
  var last4: String { get }
  var sourceType: APILinkedSourceTypeEntity { get }
  var sourceId: String { get }
}

public protocol LinkedSourceTypeEntity {
  static var externalBank: Self { get }
  static var externalCard: Self { get }
  
  var rawString: String { get }
}

import Foundation

// sourcery: AutoMockable
public protocol TaxFileEntity: Equatable {
  var name: String? { get }
  var year: String? { get }
  var url: String? { get }
  var createdAt: String? { get }
}

extension TaxFileEntity {
  public static func == (lhs: any TaxFileEntity, rhs: any TaxFileEntity) -> Bool {
    return lhs.name == rhs.name && lhs.year == rhs.year && lhs.url == rhs.url && lhs.createdAt == rhs.createdAt
  }
}

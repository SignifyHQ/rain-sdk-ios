import Foundation
import SolidDomain

public struct APISolidAccountStatementList: Codable, SolidAccountStatementListEntity {
  public var month: String
  public var year: String
  public var createdAt: String
}

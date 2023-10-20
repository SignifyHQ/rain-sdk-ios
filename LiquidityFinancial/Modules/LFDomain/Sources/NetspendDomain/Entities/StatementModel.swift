import Foundation

public struct StatementListReponse: Codable {
  public var statements: [StatementModel]
}

public struct StatementModel: Codable, Equatable {
  public var period: String
  public var url: String
  public var name: String
  public var createdAt: String
}

extension StatementModel {
  public static func == (lhs: StatementModel, rhs: StatementModel) -> Bool {
    return lhs.period == rhs.period && lhs.url == rhs.url
  }
}

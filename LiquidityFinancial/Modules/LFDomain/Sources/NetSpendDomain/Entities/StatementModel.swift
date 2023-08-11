import Foundation

public struct StatementListReponse: Codable {
  public var statements: [StatementModel]
}

public struct StatementModel: Codable {
  public var period: String
  public var url: String
}

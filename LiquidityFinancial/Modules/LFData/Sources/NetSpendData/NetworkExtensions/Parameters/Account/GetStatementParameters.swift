import Foundation
import NetspendDomain
import NetworkUtilities

public struct GetStatementParameters: Parameterable, GetStatementParameterEntity {
  public let fromMonth: String
  public let fromYear: String
  public let toMonth: String
  public let toYear: String
  
  public init(fromMonth: String, fromYear: String, toMonth: String, toYear: String) {
    self.fromMonth = fromMonth
    self.fromYear = fromYear
    self.toMonth = toMonth
    self.toYear = toYear
  }
}

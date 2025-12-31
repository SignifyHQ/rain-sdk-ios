import Foundation
import RainDomain

public struct APIOccupation: OccupationEntity {
  public var code: String
  public var occupation: String
  
  public init(
    code: String,
    occupation: String
  ) {
    self.code = code
    self.occupation = occupation
  }
}

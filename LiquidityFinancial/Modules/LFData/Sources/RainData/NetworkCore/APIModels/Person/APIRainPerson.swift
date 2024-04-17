import Foundation
import RainDomain

public struct APIRainPerson: Decodable {
  public let liquidityUserId: String
  public let internalPersonId: String
  public let externalPersonId: String
}

extension APIRainPerson: RainPersonEntity {}

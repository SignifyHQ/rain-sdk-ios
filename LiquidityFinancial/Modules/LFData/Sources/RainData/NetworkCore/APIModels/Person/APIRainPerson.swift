import Foundation
import RainDomain

public struct APIRainPerson: Decodable {
  public let liquidityUserId: String
  public let rainInternalPersonId: String
  public let rainExternalPersonId: String
}

extension APIRainPerson: RainPersonEntity {}

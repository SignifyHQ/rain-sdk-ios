import Foundation
import CardDomain

public struct APIVerifyCVVResponse: Decodable, VerifyCVVCodeEntity {
  public let id: String
}

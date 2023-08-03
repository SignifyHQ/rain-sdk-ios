import Foundation
import CardDomain

public struct APIVerifyCVVCode: Decodable, VerifyCVVCodeEntity {
  public let id: String
}

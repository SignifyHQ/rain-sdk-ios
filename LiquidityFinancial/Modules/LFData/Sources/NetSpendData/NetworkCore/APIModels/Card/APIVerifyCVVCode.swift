import Foundation
import NetspendDomain

public struct APIVerifyCVVCode: Decodable, VerifyCVVCodeEntity {
  public let id: String
}

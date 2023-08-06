import Foundation
import NetSpendDomain

public struct APIVerifyCVVCode: Decodable, VerifyCVVCodeEntity {
  public let id: String
}

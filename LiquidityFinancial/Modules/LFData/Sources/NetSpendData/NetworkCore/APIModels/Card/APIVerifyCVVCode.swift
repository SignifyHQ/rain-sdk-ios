import Foundation
import BankDomain

public struct APIVerifyCVVCode: Decodable, VerifyCVVCodeEntity {
  public let id: String
}

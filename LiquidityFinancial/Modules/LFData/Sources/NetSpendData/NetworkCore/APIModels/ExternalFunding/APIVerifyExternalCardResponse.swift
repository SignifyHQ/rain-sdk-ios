import Foundation
import BankDomain

public struct APIVerifyExternalCardResponse: VerifyExternalCardResponseEntity, Decodable {
  public let cardId: String
}

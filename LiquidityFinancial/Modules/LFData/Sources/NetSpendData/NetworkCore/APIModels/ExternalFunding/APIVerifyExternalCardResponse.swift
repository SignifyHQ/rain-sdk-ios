import Foundation
import NetSpendDomain

public struct APIVerifyExternalCardResponse: VerifyExternalCardResponseEntity, Decodable {
  public let cardId: String
}

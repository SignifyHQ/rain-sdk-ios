import Foundation
import NetspendDomain

public struct APIVerifyExternalCardResponse: VerifyExternalCardResponseEntity, Decodable {
  public let cardId: String
}

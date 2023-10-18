import Foundation
import BankDomain

public struct APIExternalCard: ExternalCardEntity, Decodable {
  public var cardId: String
}

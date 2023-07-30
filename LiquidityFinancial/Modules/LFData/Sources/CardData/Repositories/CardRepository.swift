import Foundation
import CardDomain

public class CardRepository: CardRepositoryProtocol {
  private let cardAPI: CardAPIProtocol
  
  public init(cardAPI: CardAPIProtocol) {
    self.cardAPI = cardAPI
  }
  
  public func getListCard() async throws -> [CardEntity] {
    return try await cardAPI.getListCard()
  }
}

extension APICard: CardEntity {
  public var shippingAddressEntity: CardDomain.ShippingAddressEntity? {
    shippingAddress
  }
}

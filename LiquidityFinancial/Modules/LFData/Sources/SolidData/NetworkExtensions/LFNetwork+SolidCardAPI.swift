import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: SolidCardAPIProtocol where R == SolidCardRoute {
  
  public func getListCard() async throws -> [APISolidCard] {
    let response = try await request(
      SolidCardRoute.listCard,
      target: APIListObject<APISolidCard>.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
    return response.data
  }
  
  public func updateCardStatus(cardID: String, parameters: APISolidCardStatusParameters) async throws -> APISolidCard {
    try await request(
      SolidCardRoute.updateCardStatus(cardID: cardID, parameters: parameters),
      target: APISolidCard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func closeCard(cardID: String) async throws -> Bool {
    let statusCode = try await request(
      SolidCardRoute.closeCard(cardID: cardID)
    ).httpResponse?.statusCode
    
    return statusCode?.isSuccess ?? false
  }
  
}

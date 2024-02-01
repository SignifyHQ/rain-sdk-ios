import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: SolidCardAPIProtocol where R == SolidCardRoute {
  public func getCardLimits(cardID: String) async throws -> APISolidCardLimits {
    return try await request(
      SolidCardRoute.getCardLimits(cardID: cardID),
      target: APISolidCardLimits.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getListCard(isContainClosedCard: Bool) async throws -> [APISolidCard] {
    let response = try await request(
      SolidCardRoute.listCard(isContainClosedCard: isContainClosedCard),
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
    let response = try await request(
      SolidCardRoute.closeCard(cardID: cardID)
    )
    
    let statusCode = (response.httpResponse?.statusCode ?? 500).isSuccess
    if !statusCode, let data = response.data {
      try LFCoreNetwork.processingStringError(data)
    }
    
    return statusCode
  }
  
  public func createVGSShowToken(cardID: String) async throws -> APISolidCardShowToken {
    try await request(
      SolidCardRoute.createVGSShowToken(cardID: cardID),
      target: APISolidCardShowToken.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func createDigitalWalletLink(
    cardID: String,
    parameters: APISolidApplePayWalletParameters
  ) async throws -> APISolidDigitalWallet {
    let requestParameters = APISolidDigitalWalletParameters(wallet: "applePay", applePay: parameters)
    return try await request(
      SolidCardRoute.createDigitalWalletLink(cardID: cardID, parameters: requestParameters),
      target: APISolidDigitalWallet.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func createVirtualCard(accountID: String) async throws -> APISolidCard {
    try await request(
      SolidCardRoute.createVirtualCard(accountID: accountID),
      target: APISolidCard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func updateRoundUpDonation(cardID: String, parameters: APISolidRoundUpDonationParameters) async throws -> APISolidCard {
    try await request(
      SolidCardRoute.updateRoundUpDonation(cardID: cardID, parameters: parameters),
      target: APISolidCard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func createCardPinToken(cardID: String) async throws -> APISolidCardPinToken {
    try await request(
      SolidCardRoute.createCardPinToken(cardID: cardID),
      target: APISolidCardPinToken.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func activeCard(cardID: String, parameters: APISolidActiveCardParameters) async throws -> APISolidCard {
    try await request(
      SolidCardRoute.activeCard(cardID: cardID, parameters: parameters),
      target: APISolidCard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func updateCardName(cardID: String, parameters: APISolidCardNameParameters) async throws -> APISolidCard {
    try await request(
      SolidCardRoute.updateCardName(cardID: cardID, parameters: parameters),
      target: APISolidCard.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}

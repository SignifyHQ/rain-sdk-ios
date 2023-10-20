import Foundation
import NetspendDomain
import NetspendSdk

// swiftlint: disable force_cast
public class NSCardRepository: NSCardRepositoryProtocol {
  private let cardAPI: NSCardAPIProtocol
  
  public init(cardAPI: NSCardAPIProtocol) {
    self.cardAPI = cardAPI
  }
  
  public func getListCard() async throws -> [CardEntity] {
    try await cardAPI.getListCard()
  }
  
  public func createCard(sessionID: String) async throws -> CardEntity {
    try await cardAPI.createCard(sessionID: sessionID)
  }
  
  public func getCard(cardID: String, sessionID: String) async throws -> CardEntity {
    try await cardAPI.getCard(cardID: cardID, sessionID: sessionID)
  }
  
  public func lockCard(cardID: String, sessionID: String) async throws -> CardEntity {
    try await cardAPI.lockCard(cardID: cardID, sessionID: sessionID)
  }
  
  public func unlockCard(cardID: String, sessionID: String) async throws -> CardEntity {
    try await cardAPI.unlockCard(cardID: cardID, sessionID: sessionID)
  }
  
  public func closeCard(reason: CloseCardReasonEntity, cardID: String, sessionID: String) async throws -> CardEntity {
    let reasonRequest = CloseCardReasonParameters(reason: reason.reason)
    return try await cardAPI.closeCard(reason: reasonRequest, cardID: cardID, sessionID: sessionID)
  }
  
  public func orderPhysicalCard(address: AddressCardParametersEntity, sessionID: String) async throws -> CardEntity {
    return try await cardAPI.orderPhysicalCard(address: address as! AddressCardParameters, sessionID: sessionID)
  }
  
  public func verifyCVVCode(verifyRequest: VerifyCVVCodeParametersEntity, cardID: String, sessionID: String) async throws -> VerifyCVVCodeEntity {
    return try await cardAPI.verifyCVVCode(verifyRequest: verifyRequest as! VerifyCVVCodeParameters, cardID: cardID, sessionID: sessionID)
  }
  
  public func setPin(requestParam: SetPinRequestEntity, cardID: String, sessionID: String) async throws -> CardEntity {
    let apiRequest = APISetPinRequest(verifyId: requestParam.verifyId, encryptedData: requestParam.encryptedData)
    return try await cardAPI.setPin(requestParam: apiRequest, cardID: cardID, sessionID: sessionID)
  }
  
  public func getApplePayToken(sessionId: String, cardId: String) async throws -> any GetApplePayTokenEntity {
    return try await cardAPI.getApplePayToken(sessionId: sessionId, cardId: cardId)
  }
  
  public func postApplePayToken(sessionId: String, cardId: String, bodyData: [String: Any]) async throws -> PostApplePayTokenEntity {
    return try await cardAPI.postApplePayToken(sessionId: sessionId, cardId: cardId, bodyData: bodyData)
  }
}

extension APICard: CardEntity {
  public func decodeData<T: CardEncryptedEntity>(session: NetspendSdkUserSession) -> T? {
    APICard.decodeData(session: session, encryptedData: encryptedData) as? T
  }
  
  public var shippingAddressEntity: NetspendDomain.ShippingAddressEntity? {
    shippingAddress
  }
}

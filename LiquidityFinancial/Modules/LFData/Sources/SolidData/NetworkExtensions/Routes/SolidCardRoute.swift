import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities
import SolidDomain

public enum SolidCardRoute {
  case listCard
  case updateCardStatus(cardID: String, parameters: APISolidCardStatusParameters)
  case closeCard(cardID: String)
  case createVGSShowToken(cardID: String)
  case createDigitalWalletLink(cardID: String, parameters: APISolidDigitalWalletParameters)
  case createVirtualCard(accountID: String)
  case updateRoundUpDonation(cardID: String, parameters: APISolidRoundUpDonationParameters)
}

extension SolidCardRoute: LFRoute {

  public var path: String {
    switch self {
    case .listCard:
      return "/v1/solid/cards"
    case let .updateCardStatus(cardID, _):
      return "/v1/solid/cards/\(cardID)/status"
    case let .closeCard(cardID):
      return "/v1/solid/cards/\(cardID)"
    case let .createVGSShowToken(cardID):
      return "/v1/solid/cards/\(cardID)/show-token"
    case let .createDigitalWalletLink(cardID, _):
      return "/v1/solid/cards/\(cardID)/digital-wallet-provision"
    case let .createVirtualCard(accountID):
      return "/v1/solid/cards/virtual-card/\(accountID)"
    case let .updateRoundUpDonation(cardID, _):
      return "/v1/solid/cards/\(cardID)/round-up-config"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .listCard:
      return .GET
    case .updateCardStatus, .updateRoundUpDonation:
      return .PATCH
    case .closeCard:
      return .DELETE
    case .createVGSShowToken, .createDigitalWalletLink, .createVirtualCard:
      return .POST
    }
  }
  
  public var httpHeaders: HttpHeaders {
    [
      "Content-Type": "application/json",
      "productId": NetworkUtilities.productID,
      "Authorization": self.needAuthorizationKey,
      "Accept": "application/json",
      "ld-device-id": LFUtilities.deviceId
    ]
  }
  
  public var parameters: Parameters? {
    switch self {
    case .listCard, .closeCard, .createVGSShowToken, .createVirtualCard:
      return nil
    case let .updateCardStatus(_, parameters):
      return parameters.encoded()
    case let .updateRoundUpDonation(_, parameters):
      return parameters.encoded()
    case let .createDigitalWalletLink(_, parameters):
      return parameters.encoded()
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .listCard, .closeCard, .createVGSShowToken, .createVirtualCard:
      return nil
    case .updateCardStatus, .createDigitalWalletLink, .updateRoundUpDonation:
      return .json
    }
  }
  
}

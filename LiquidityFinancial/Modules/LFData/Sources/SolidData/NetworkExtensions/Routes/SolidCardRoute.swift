import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities
import SolidDomain

public enum SolidCardRoute {
  case listCard(isContainClosedCard: Bool)
  case updateCardStatus(cardID: String, parameters: APISolidCardStatusParameters)
  case updateRoundUpDonation(cardID: String, parameters: APISolidRoundUpDonationParameters)
  case closeCard(cardID: String)
  case createVGSShowToken(cardID: String)
  case createDigitalWalletLink(cardID: String, parameters: APISolidDigitalWalletParameters)
  case createVirtualCard(accountID: String)
  case createCardPinToken(cardID: String)
  case activeCard(cardID: String, parameters: APISolidActiveCardParameters)
  case getCardLimits(cardID: String)
  case updateCardName(cardID: String, parameters: APISolidCardNameParameters)
  case getCardTransactions(parameters: APISolidCardTransactionsParameters)
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
    case let .createCardPinToken(cardID):
      return "/v1/solid/cards/\(cardID)/pin-token"
    case let .activeCard(cardID, _):
      return "/v1/solid/cards/\(cardID)/activate"
    case let .getCardLimits(cardID):
      return "/v1/solid/cards/\(cardID)/limits"
    case let .updateCardName(cardID, _):
      return "/v1/solid/cards/\(cardID)/name"
    case .getCardTransactions:
      return "/v1/transactions/by-card-id"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .listCard, .getCardLimits, .getCardTransactions:
      return .GET
    case .updateCardStatus, .updateRoundUpDonation, .activeCard, .updateCardName:
      return .PATCH
    case .closeCard:
      return .DELETE
    case .createVGSShowToken, .createDigitalWalletLink, .createVirtualCard, .createCardPinToken:
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
    case .closeCard, .createVGSShowToken, .createVirtualCard, .createCardPinToken, .getCardLimits:
      return nil
    case let .updateCardStatus(_, parameters):
      return parameters.encoded()
    case let .updateRoundUpDonation(_, parameters):
      return parameters.encoded()
    case let .createDigitalWalletLink(_, parameters):
      return parameters.encoded()
    case let .activeCard(_, parameters):
      return parameters.encoded()
    case let .listCard(isContainClosedCard):
      return [
        "showClosed": "\(isContainClosedCard)"
      ]
    case let .updateCardName(_, parameters):
      return parameters.encoded()
    case let .getCardTransactions(parameters):
      return parameters.encoded()
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .closeCard, .createVGSShowToken, .createVirtualCard, .createCardPinToken, .getCardLimits:
      return nil
    case .updateCardStatus, .createDigitalWalletLink, .updateRoundUpDonation, .activeCard, .updateCardName:
      return .json
    case .listCard, .getCardTransactions:
      return .url
    }
  }
  
}

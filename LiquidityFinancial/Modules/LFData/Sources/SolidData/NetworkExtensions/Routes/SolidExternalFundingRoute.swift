import CoreNetwork
import NetworkUtilities
import AuthorizationManager
import LFUtilities
import SolidDomain

public enum SolidExternalFundingRoute {
  case getLinkedSources(accountId: String)
  case createDebitCardToken(accountID: String)
  case createPlaidToken(accountId: String)
  case plaidLink(accountId: String, token: String, plaidAccountId: String)
  case unlinkContact(id: String)
  case getWireTransfer(accountId: String)
  case newTransaction(type: SolidExternalTransactionType, accountId: String, contactId: String, amount: Double)
  case estimateDebitCardFee(accountId: String, contactId: String, amount: Double)
  case createPinwheelToken(accountId: String)
  case cancelACHTransaction(liquidityTransactionID: String)
}

extension SolidExternalFundingRoute: LFRoute {

  public var path: String {
    switch self {
    case .getLinkedSources:
      return "/v1/solid/external-funding/linked-sources"
    case .createDebitCardToken:
      return "/v1/solid/external-funding/linked-sources/debit-card/token"
    case .createPlaidToken:
      return "/v1/solid/external-funding/linked-sources/plaid/token"
    case .plaidLink:
      return "/v1/solid/external-funding/linked-sources/plaid/link"
    case .unlinkContact(let id):
      return "/v1/solid/external-funding/linked-sources/\(id)"
    case .getWireTransfer:
      return "/v1/solid/external-funding/linked-sources/wire-transfer"
    case .createPinwheelToken:
      return "/v1/solid/external-funding/linked-sources/pinwheel/token"
    case .newTransaction(let type, _, _, _):
      switch type {
      case .withdraw:
        return "/v1/solid/external-funding/withdraw"
      case .deposit:
        return "/v1/solid/external-funding/deposit"
      }
    case .estimateDebitCardFee:
      return "/v1/solid/external-funding/estimate-debit-card-fee"
    case .cancelACHTransaction:
      return "/v1/solid/external-funding/cancel-ach"
    }
  }
  
  public var httpMethod: HttpMethod {
    switch self {
    case .getLinkedSources, .getWireTransfer:
      return .GET
    case .createDebitCardToken, .createPlaidToken, .plaidLink, .createPinwheelToken:
      return .POST
    case .unlinkContact:
      return .DELETE
    case .newTransaction:
      return .POST
    case .estimateDebitCardFee:
      return .POST
    case .cancelACHTransaction:
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
    case .getLinkedSources(let accountId), .getWireTransfer(let accountId):
      return [
        "accountId": accountId
      ]
    case .unlinkContact:
      return nil
    case .createDebitCardToken(let accountID), .createPinwheelToken(let accountID):
      return [
        "liquidityAccountId": accountID
      ]
    case .createPlaidToken(let id):
      return [
        "liquidityAccountId": id
      ]
    case .plaidLink(let accountId, let token, let plaidAccountId):
      return [
        "liquidityAccountId": accountId,
        "publicToken": token,
        "plaidAccountId": plaidAccountId
      ]
    case .newTransaction(_, let accountId, let contactId, let amount):
      return [
        "liquidityAccountId": accountId,
        "contactId": contactId,
        "amount": amount
      ]
    case .estimateDebitCardFee(let accountId, let contactId, let amount):
      return [
        "liquidityAccountId": accountId,
        "contactId": contactId,
        "amount": amount
      ]
    case .cancelACHTransaction(let liquidityTransactionID):
      return [
        "liquidityTransactionId": liquidityTransactionID
      ]
    }
  }
  
  public var parameterEncoding: ParameterEncoding? {
    switch self {
    case .createDebitCardToken,
        .createPlaidToken,
        .plaidLink,
        .newTransaction,
        .estimateDebitCardFee,
        .createPinwheelToken,
        .cancelACHTransaction:
      return .json
    case .getLinkedSources, .getWireTransfer:
      return .url
    case .unlinkContact:
      return nil
    }
  }
  
}

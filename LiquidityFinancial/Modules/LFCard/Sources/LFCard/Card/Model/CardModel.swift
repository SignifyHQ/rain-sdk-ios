import Foundation
import LFLocalizable

public struct CardModel: Identifiable, Hashable {
  public let id: String
  public let cardType: CardType
  public let cardholderName: String?
  public let expiryMonth: String
  public let expiryYear: String
  public let last4: String
  public var cardStatus: CardStatus
  
  public static let virtualDefault = CardModel(
    id: "",
    cardType: .virtual,
    cardholderName: nil,
    expiryMonth: "09",
    expiryYear: "2023",
    last4: "1891",
    cardStatus: .active
  )
}

public enum CardStatus: String {
  case active
  case closed
  case disabled
  case unactivated
  
  public init?(rawValue: String) {
    switch rawValue {
    case "active":
      self = .active
    case "closed":
      self = .closed
    case "disabled":
      self = .disabled
    case "unactivated":
      self = .unactivated
    default:
      self = .unactivated
    }
  }
}

public enum CardType {
  case virtual
  case physical
  
  public init?(rawValue: String) {
    switch rawValue {
    case "virtual": self = .virtual
    case "physical": self = .physical
    default:
      self = .virtual
    }
  }
  
  public var title: String {
    switch self {
    case .virtual:
      return LFLocalizable.Card.Virtual.title
    case .physical:
      return LFLocalizable.Card.Physical.title
    }
  }
}

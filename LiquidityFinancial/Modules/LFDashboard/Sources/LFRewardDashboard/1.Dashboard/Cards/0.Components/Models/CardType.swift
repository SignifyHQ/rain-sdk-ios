import Foundation
import LFLocalizable

public enum CardType {
  case virtual
  case physical
  
  public init?(rawValue: String) {
    switch rawValue {
    case "virtual":
      self = .virtual
    case "physical":
      self = .physical
    default:
      self = .virtual
    }
  }
  
  public var title: String {
    switch self {
    case .virtual:
      return L10N.Common.Card.Virtual.title
    case .physical:
      return L10N.Common.Card.Physical.title
    }
  }
}

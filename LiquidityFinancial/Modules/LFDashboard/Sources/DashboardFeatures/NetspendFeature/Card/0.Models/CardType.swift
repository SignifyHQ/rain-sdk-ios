import Foundation
import LFLocalizable

enum CardType {
  case virtual
  case physical
  
  init?(rawValue: String) {
    switch rawValue {
    case "virtual": self = .virtual
    case "physical": self = .physical
    default:
      self = .virtual
    }
  }
  
  var title: String {
    switch self {
    case .virtual:
      return LFLocalizable.Card.Virtual.title
    case .physical:
      return LFLocalizable.Card.Physical.title
    }
  }
}

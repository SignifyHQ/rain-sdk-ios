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
      return L10N.Common.Card.Virtual.title
    case .physical:
      return L10N.Common.Card.Physical.title
    }
  }
}

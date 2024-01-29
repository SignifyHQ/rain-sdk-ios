import Foundation
import SwiftUI
import LFLocalizable

enum CardListType {
  case open
  case closed
  
  var title: String {
    switch self {
    case .open:
      return L10N.Common.Card.OpenCards.title
    case .closed:
      return L10N.Common.Card.CloseCards.title
    }
  }
}

import Foundation
import LFLocalizable

enum FundraiserSelectionType {
  case notAllowed
  case allowed(onSelect: (() -> Void)?)
  case allowedBeforeAccountCreation(onSelect: (() -> Void)?)
  
  var allowSelection: Bool {
    switch self {
    case .notAllowed:
      return false
    case .allowed, .allowedBeforeAccountCreation:
      return true
    }
  }
  
  func format(_ param: String) -> String {
    switch self {
    case .notAllowed:
      return ""
    case .allowed:
      return LFLocalizable.FundraiserSelection.allowed(param)
    case .allowedBeforeAccountCreation:
      return LFLocalizable.FundraiserSelection.allowedBeforeAccountCreation(param)
    }
  }
  
  var onSelect: (() -> Void)? {
    switch self {
    case .notAllowed:
      return nil
    case let .allowed(onSelect), let .allowedBeforeAccountCreation(onSelect):
      return onSelect
    }
  }
}

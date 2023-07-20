import Foundation
import LFLocalizable

enum DocumentType {
  case foreignID
  case other
  case passport
  case payStub
  case socialSecurityCard
  case stateID
  case utilityBill
  
  var title: String {
    switch self {
      case .foreignID:
        return LFLocalizable.DocumentType.ForeignID.title
      case .other:
        return LFLocalizable.DocumentType.Other.title
      case .passport:
        return LFLocalizable.DocumentType.Passport.title
      case .payStub:
        return LFLocalizable.DocumentType.PayStub.title
      case .socialSecurityCard:
        return LFLocalizable.DocumentType.SocialSecurityCard.title
      case .stateID:
        return LFLocalizable.DocumentType.StateID.title
      case .utilityBill:
        return LFLocalizable.DocumentType.UtilityBill.title
    }
  }
}

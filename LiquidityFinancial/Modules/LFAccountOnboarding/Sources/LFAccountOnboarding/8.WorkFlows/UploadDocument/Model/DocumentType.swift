import Foundation
import LFLocalizable
import NetSpendData

extension NetSpendDocumentType {
  var title: String {
    switch self {
    case .foreignId:
      return LFLocalizable.DocumentType.ForeignID.title
    case .other:
      return LFLocalizable.DocumentType.Other.title
    case .passport:
      return LFLocalizable.DocumentType.Passport.title
    case .payStubDatedWithin30Days:
      return LFLocalizable.DocumentType.PayStub.title
    case .socialSecurityCard:
      return LFLocalizable.DocumentType.SocialSecurityCard.title
    case .stateIssuedPhotoId:
      return LFLocalizable.DocumentType.StateID.title
    case .utilityBill:
      return LFLocalizable.DocumentType.UtilityBill.title
    }
  }
  
  var displayTypes: DocumentDisplayType {
    switch self {
    case .foreignId:
      return .all
    case .other:
      return .front
    case .passport:
      return .all
    case .payStubDatedWithin30Days:
      return .front
    case .socialSecurityCard:
      return .all
    case .stateIssuedPhotoId:
      return .all
    case .utilityBill:
      return .front
    }
  }
  
  var documentType: String {
    switch self {
    case .foreignId:
      return NetSpendDocumentRequestContentTypes.jpeg.rawValue
    case .other:
      return NetSpendDocumentRequestContentTypes.jpeg.rawValue
    case .passport:
      return NetSpendDocumentRequestContentTypes.jpeg.rawValue
    case .payStubDatedWithin30Days:
      return NetSpendDocumentRequestContentTypes.jpeg.rawValue
    case .socialSecurityCard:
      return NetSpendDocumentRequestContentTypes.jpeg.rawValue
    case .stateIssuedPhotoId:
      return NetSpendDocumentRequestContentTypes.jpeg.rawValue
    case .utilityBill:
      return NetSpendDocumentRequestContentTypes.jpeg.rawValue
    }
  }
}

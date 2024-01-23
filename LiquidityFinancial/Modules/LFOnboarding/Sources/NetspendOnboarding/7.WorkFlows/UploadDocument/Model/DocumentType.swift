import Foundation
import LFLocalizable
import NetSpendData

extension NetSpendDocumentType {
  var title: String {
    switch self {
    case .foreignId:
      return L10N.Common.DocumentType.ForeignID.title
    case .other:
      return L10N.Common.DocumentType.Other.title
    case .passport:
      return L10N.Common.DocumentType.Passport.title
    case .payStubDatedWithin30Days:
      return L10N.Common.DocumentType.PayStub.title
    case .socialSecurityCard:
      return L10N.Common.DocumentType.SocialSecurityCard.title
    case .stateIssuedPhotoId:
      return L10N.Common.DocumentType.StateID.title
    case .utilityBill:
      return L10N.Common.DocumentType.UtilityBill.title
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
  
  func getMimeType(from url: URL) -> String {
    guard let data = try? Data(contentsOf: url) else { return "uknown" }
    return data.fileExtension
  }
}

// swiftlint:disable all
extension Data {
  private static let mimeTypeSignatures: [UInt8 : String] = [
    0xFF : "image/jpeg",
    0x89 : "image/png",
    0x47 : "image/gif",
    0x25 : "application/pdf",
  ]
  
  var mimeType: String {
    var c: UInt8 = 0
    copyBytes(to: &c, count: 1)
    return Data.mimeTypeSignatures[c] ?? "application/octet-stream"
  }
  
  var fileExtension: String {
    switch mimeType {
    case "image/jpeg":
      return "image/jpeg"
    case "image/png":
      return "image/png"
    case "image/gif":
      return "image/gif"
    case "application/pdf":
      return "application/pdf"
    default:
      return "uknown"
    }
  }
}

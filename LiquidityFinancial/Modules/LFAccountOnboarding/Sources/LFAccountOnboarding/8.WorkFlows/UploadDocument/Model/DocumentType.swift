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
  
  func getMimeType(from url: URL) -> String {
    guard let data = try? Data(contentsOf: url) else { return "uknown" }
    return data.fileExtension
  }
}

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

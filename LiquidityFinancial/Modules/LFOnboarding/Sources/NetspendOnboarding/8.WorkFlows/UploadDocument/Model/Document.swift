import LFUtilities
import SwiftUI
import NetSpendData

struct Document: Identifiable {
  let id = UUID()
  let filePath: URL
  let fileSize: Double
  let fileType: NetSpendDocumentType
  let documentDisplayType: DocumentDisplayType
  var fileName: String {
    guard let fileName = filePath.lastPathComponent.components(separatedBy: ".").first else {
      return ""
    }
    return fileName
  }
}

enum DocumentDisplayType {
  case front
  case back
  case all
  case none
  
  var title: String {
    switch self {
    case .front:
      return "Front"
    case .back:
      return "Back"
    case .all, .none:
      return ""
    }
  }
  
  var desc: String {
    switch self {
    case .front:
      return "front_image_content_type"
    case .back:
      return "back_image_content_type"
    case .all, .none:
      return ""
    }
  }
}

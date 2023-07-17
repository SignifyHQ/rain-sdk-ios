import LFUtilities
import SwiftUI

struct Document: Identifiable {
  let id = UUID()
  let filePath: URL
  let fileSize: Double
  
  var fileName: String {
    guard let fileName = filePath.lastPathComponent.components(separatedBy: ".").first else {
      return ""
    }
    return fileName
  }
  
  var formartFizeSize: String {
    String(format: "%.1f \(Constants.Default.capacityUnit.rawValue)", fileSize)
  }
}

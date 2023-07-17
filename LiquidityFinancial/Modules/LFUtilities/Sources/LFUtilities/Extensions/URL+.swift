import Foundation

public extension URL {
  var size: Double {
    defer {
      self.stopAccessingSecurityScopedResource()
    }
    let _ = self.startAccessingSecurityScopedResource()
    guard let attributes = try? FileManager.default.attributesOfItem(atPath: self.path) else {
      return 0
    }
    let size = attributes[.size] as? Double ?? 0
    return size * pow(10, -3)
  }
}

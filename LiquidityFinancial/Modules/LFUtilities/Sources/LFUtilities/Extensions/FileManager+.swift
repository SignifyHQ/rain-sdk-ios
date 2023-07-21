import Foundation

public extension FileManager {
  func clearTmpDirectory() {
    do {
      let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
      try tmpDirectory.forEach { [weak self] file in
        let path = String(format: "%@%@", NSTemporaryDirectory(), file)
        log.debug("path: \(path)")
        try self?.removeItem(atPath: path)
      }
    } catch {
      log.error(error)
    }
  }
}

public extension FileManager {
  func sizeOfFile(atPath path: String) -> Int64? {
    guard let attrs = try? attributesOfItem(atPath: path) else {
      return nil
    }
    
    return attrs[.size] as? Int64
  }
}

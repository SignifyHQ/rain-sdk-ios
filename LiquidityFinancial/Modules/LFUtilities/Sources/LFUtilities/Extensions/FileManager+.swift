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

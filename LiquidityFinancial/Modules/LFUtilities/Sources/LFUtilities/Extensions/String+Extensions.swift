import Foundation

// MARK: - Transform Extension
public extension String {
  func trimWhitespacesAndNewlines() -> String {
    trimmingCharacters(in: .whitespacesAndNewlines)
  }
}

import Foundation
import Combine

// MARK: - RainServiceProtocol
public protocol RainServiceProtocol {
  func generateSessionId() -> String
  func decryptData(ivBase64: String, dataBase64: String) -> String
}

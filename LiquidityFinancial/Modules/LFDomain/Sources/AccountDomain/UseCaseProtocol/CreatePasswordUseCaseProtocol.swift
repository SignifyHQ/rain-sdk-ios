import Foundation

public protocol CreatePasswordUseCaseProtocol {
  func execute(password: String) async throws
}

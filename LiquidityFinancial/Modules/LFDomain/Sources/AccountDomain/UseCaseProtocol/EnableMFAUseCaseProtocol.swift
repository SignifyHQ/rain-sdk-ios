import Foundation

public protocol EnableMFAUseCaseProtocol {
  func execute(code: String) async throws -> EnableMFAEntity
}

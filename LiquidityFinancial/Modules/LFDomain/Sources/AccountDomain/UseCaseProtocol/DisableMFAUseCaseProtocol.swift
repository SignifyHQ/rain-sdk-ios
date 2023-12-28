import Foundation

public protocol DisableMFAUseCaseProtocol {
  func execute(code: String) async throws -> DisableMFAEntity
}

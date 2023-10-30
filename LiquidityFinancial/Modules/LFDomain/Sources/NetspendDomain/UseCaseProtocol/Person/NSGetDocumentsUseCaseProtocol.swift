import Foundation

public protocol NSGetDocumentsUseCaseProtocol {
  func execute(sessionId: String) async throws -> DocumentDataEntity
}

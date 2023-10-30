import Foundation

public protocol NSPutQuestionUseCaseProtocol {
  func execute(sessionId: String, encryptedData: String) async throws -> Bool
}

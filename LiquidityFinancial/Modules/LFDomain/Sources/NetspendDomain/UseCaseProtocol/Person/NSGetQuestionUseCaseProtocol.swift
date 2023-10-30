import Foundation

public protocol NSGetQuestionUseCaseProtocol {
  func execute(sessionId: String) async throws -> QuestionDataEntiy
}

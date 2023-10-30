import Foundation

public class NSGetQuestionUseCase: NSGetQuestionUseCaseProtocol {
  private let repository: NSPersonsRepositoryProtocol
  
  public init(repository: NSPersonsRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(sessionId: String) async throws -> QuestionDataEntiy {
    try await repository.getQuestion(sessionId: sessionId)
  }
}

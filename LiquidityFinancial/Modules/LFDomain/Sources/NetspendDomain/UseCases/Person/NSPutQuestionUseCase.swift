import Foundation

public class NSPutQuestionUseCase: NSPutQuestionUseCaseProtocol {
  private let repository: NSPersonsRepositoryProtocol
  
  public init(repository: NSPersonsRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(sessionId: String, encryptedData: String) async throws -> Bool {
    try await repository.putQuestion(sessionId: sessionId, encryptedData: encryptedData)
  }
}

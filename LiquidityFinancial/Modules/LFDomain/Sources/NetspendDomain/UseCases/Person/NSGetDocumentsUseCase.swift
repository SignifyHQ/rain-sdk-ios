import Foundation

public class NSGetDocumentsUseCase: NSGetDocumentsUseCaseProtocol {
  private let repository: NSPersonsRepositoryProtocol
  
  public init(repository: NSPersonsRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(sessionId: String) async throws -> DocumentDataEntity {
    try await repository.getDocuments(sessionId: sessionId)
  }
}

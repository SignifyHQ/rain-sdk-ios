import Foundation

public class NSUploadDocumentsUseCase: NSUploadDocumentsUseCaseProtocol {
  private let repository: NSPersonsRepositoryProtocol
  
  public init(repository: NSPersonsRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(path: PathDocumentParametersEntity, documentData: any DocumentParametersEntity) async throws -> UploadRequestedDocumentEntity {
    try await repository.uploadDocuments(path: path, documentData: documentData)
  }
}

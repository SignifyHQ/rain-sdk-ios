import Foundation

public protocol NSUploadDocumentsUseCaseProtocol {
  func execute(path: PathDocumentParametersEntity, documentData: any DocumentParametersEntity) async throws -> UploadRequestedDocumentEntity
}

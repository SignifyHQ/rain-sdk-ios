import Foundation

public protocol UploadRequestedDocumentEntity {
  var documentRequestId: String { get }
}

public protocol PathDocumentParametersEntity {
  var sessionId: String { get }
  var documentID: String { get }
  var isUpdate: Bool { get }
  init(sessionId: String, documentID: String, isUpdate: Bool)
}

public protocol DocumentParametersEntity {
  associatedtype Document: NSDocumentEntity
  var purpose: String { get }
  var documents: [Document] { get }
  init(purpose: String, documents: [Document])
}

public protocol NSDocumentEntity {
  var documentType: String { get }
  var country: String { get }
  var encryptedData: String { get }
  init(documentType: String, country: String, encryptedData: String)
}

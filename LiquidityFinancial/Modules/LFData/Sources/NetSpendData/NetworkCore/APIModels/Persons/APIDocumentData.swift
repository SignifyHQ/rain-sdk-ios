import Foundation
import NetSpendDomain

public class APIDocumentData: Decodable, DocumentDataEntity {
  public var requestedDocuments: [RequestedDocument]
  
  public class RequestedDocument: Codable, UploadRequestedDocumentEntity {
    public var status: NetSpendDocumentReviewStatus
    public var statusReason: NetSpendDocumentReviewStatusReason
    public let workflow, documentRequestId: String
    public let documentDescription: DocumentDescription
    public let acceptedContentTypes: [NetSpendDocumentRequestContentTypes]
  }

  public class DocumentDescription: Codable {
    public let mustContain: [String]
  }
  
  public func update(status: NetSpendDocumentReviewStatus, fromID: String) {
    let item = requestedDocuments.first(where: { $0.documentRequestId == fromID })
    item?.status = status
  }
}

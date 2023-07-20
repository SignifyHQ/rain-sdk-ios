import Foundation

public struct NetSpendDocumentData: Decodable {
  public let requestedDocuments: [RequestedDocument]
  
  public struct RequestedDocument: Codable {
    public let workflow, documentRequestId, expirationTime, status: String
    public let statusReason: String
    public let documentDescription: DocumentDescription
    public let acceptedContentTypes: [String]
  }

  public struct DocumentDescription: Codable {
    public let mustContain: [String]
  }
}

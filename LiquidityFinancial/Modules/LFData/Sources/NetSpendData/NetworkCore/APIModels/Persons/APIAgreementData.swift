import Foundation
import NetSpendDomain

public struct APIAgreementData: Decodable, AgreementDataEntity {
  public let agreements: [APIAgreementData.Agreement]
  public let description: String?
  public var listDescription: [String] {
    agreements.map { $0.description }
  }
  public var listAgreementID: [String] {
    agreements.map { $0.id }
  }
    // MARK: - Agreement
  public struct Agreement: Codable {
    public let id, type: String
    public let documents: [APIAgreementData.Document]
    public let description: String
    
    public init(id: String, type: String, documents: [APIAgreementData.Document], description: String) {
      self.id = id
      self.type = type
      self.documents = documents
      self.description = description
    }
  }
  
    // MARK: - Document
  public struct Document: Codable {
    public let type: String
    public let files: [APIAgreementData.File]
    
    public init(type: String, files: [APIAgreementData.File]) {
      self.type = type
      self.files = files
    }
  }
  
    // MARK: - File
  public struct File: Codable {
    public let contentType, url: String
    
    public init(contentType: String, url: String) {
      self.contentType = contentType
      self.url = url
    }
  }
  
}

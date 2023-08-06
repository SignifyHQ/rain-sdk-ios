import Foundation

public struct APIAgreementData: Decodable {
  public let agreements: [APIAgreementData.Agreement]
  
    // MARK: - Agreement
  public struct Agreement: Codable {
    public let id, type: String
    public let documents: [APIAgreementData.Document]
    public let description: String
  }
  
    // MARK: - Document
  public struct Document: Codable {
    public let type: String
    public let files: [APIAgreementData.File]
  }
  
    // MARK: - File
  public struct File: Codable {
    public let contentType, url: String
  }

}

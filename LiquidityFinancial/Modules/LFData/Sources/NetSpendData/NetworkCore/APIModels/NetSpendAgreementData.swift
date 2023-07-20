import Foundation

public struct NetSpendAgreementData: Decodable {
  public let agreements: [NetSpendAgreementData.Agreement]
  
    // MARK: - Agreement
  public struct Agreement: Codable {
    public let id, type: String
    public let documents: [NetSpendAgreementData.Document]
  }
  
    // MARK: - Document
  public struct Document: Codable {
    public let type: String
    public let files: [NetSpendAgreementData.File]
  }
  
    // MARK: - File
  public struct File: Codable {
    public let contentType, url: String
  }

}

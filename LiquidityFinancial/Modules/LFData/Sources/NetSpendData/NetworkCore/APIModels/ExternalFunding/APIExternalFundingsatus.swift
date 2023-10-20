import Foundation
import NetspendDomain

  // MARK: - ExternalBankStatus
public struct APIExternalFundingsatus: Decodable, ExternalFundingsatusEntity {
  public let externalBankStatus: APIExternalBankStatus
  public let externalCardStatus: APIExternalCardStatus
  
    // MARK: - ExternalBankStatus
  public struct APIExternalBankStatus: Decodable, ExternalBankStatusEntity {
    public let errorCode, depositStatus, withdrawStatus: String?
    public let documents: [String]?
    public let description: String?
    public let missingSteps: [String]?
  }
  
    // MARK: - ExternalCardStatus
  public struct APIExternalCardStatus: Decodable, ExternalCardStatusEntity {
    public let errorCode: String?
    public let agreement: Agreement?
    public let description: String?
    public let sendLimits, receiveLimits: [Limit]?
    public let missingSteps: [String]?
  }
  
    // MARK: - Agreement
  public struct Agreement: Decodable, AgreementEntity {
    public let id, type: String?
    public let documents: [Document]?
    public let description: String?
  }
  
    // MARK: - Document
  public struct Document: Decodable, DocumentEntity {
    public let type: String?
    public let files: [File]?
  }
  
    // MARK: - File
  public struct File: Codable, FileEntity {
    public let contentType, url: String?
    
  }
  
    // MARK: - Limit
  public struct Limit: Codable, LimitEntity {
    public let period: String?
    public let maxAmount, maxTransfer, remainingAmount, remainingTransfer: Double?
  }
}

extension APIAgreementData {
  public init(agreement: any AgreementEntity) {
    let documents: [APIAgreementData.Document] = agreement.documents?.compactMap({ APIAgreementData.Document(entity: $0) }) ?? []
    self.init(
      agreements: [
        APIAgreementData.Agreement(
          id: agreement.id ?? "",
          type: agreement.type ?? "",
          documents: documents,
          description: agreement.description ?? ""
        )
      ],
      description: agreement.description ?? .empty
    )
  }
}

extension APIAgreementData.Document {
  public init?(entity: any DocumentEntity) {
    guard let type = entity.type, let files = entity.files else { return nil }
    let fileWarp: [APIAgreementData.File] = files.compactMap({ APIAgreementData.File(entity: $0) })
    self.init(type: type, files: fileWarp)
  }
}

extension APIAgreementData.File {
  public init?(entity: any FileEntity) {
    guard let type = entity.contentType, let url = entity.url else { return nil }
    self.init(contentType: type, url: url)
  }
}

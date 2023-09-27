import Foundation

public protocol ExternalFundingsatusEntity {
  associatedtype APIExternalBankStatus: ExternalBankStatusEntity
  associatedtype APIExternalCardStatus: ExternalCardStatusEntity
  var externalBankStatus: APIExternalBankStatus { get }
  var externalCardStatus: APIExternalCardStatus { get }
}

public protocol ExternalBankStatusEntity {
  var errorCode: String? { get }
  var depositStatus: String? { get }
  var withdrawStatus: String? { get }
  var documents: [String]? { get }
  var description: String? { get }
  var missingSteps: [String]? { get }
}

public protocol ExternalCardStatusEntity {
  associatedtype Agreement: AgreementEntity
  associatedtype Limit: LimitEntity
  var errorCode: String? { get }
  var agreement: Agreement? { get }
  var description: String? { get }
  var sendLimits: [Limit]? { get }
  var receiveLimits: [Limit]? { get }
  var missingSteps: [String]? { get }
}

  // MARK: - Agreement
public protocol AgreementEntity {
  associatedtype Document: DocumentEntity
  var id: String? { get }
  var type: String? { get }
  var documents: [Document]? { get }
  var description: String? { get }
}

  // MARK: - Document
public protocol DocumentEntity {
  associatedtype File: FileEntity
  var type: String? { get }
  var files: [File]? { get }
}

  // MARK: - File
public protocol FileEntity {
  var contentType: String? { get }
  var url: String? { get }
  
}

  // MARK: - Limit
public protocol LimitEntity {
  var period: String? { get }
  var maxAmount: Double? { get }
  var maxTransfer: Double? { get }
  var remainingAmount: Double? { get }
  var remainingTransfer: Double? { get }
}

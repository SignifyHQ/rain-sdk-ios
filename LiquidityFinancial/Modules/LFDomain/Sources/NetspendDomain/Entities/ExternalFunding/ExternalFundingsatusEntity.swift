import Foundation

// sourcery: AutoMockable
public protocol ExternalFundingsatusEntity {
  associatedtype APIExternalBankStatus: ExternalBankStatusEntity
  associatedtype APIExternalCardStatus: ExternalCardStatusEntity
  var externalBankStatus: APIExternalBankStatus { get }
  var externalCardStatus: APIExternalCardStatus { get }
}

// sourcery: AutoMockable
public protocol ExternalBankStatusEntity {
  var errorCode: String? { get }
  var depositStatus: String? { get }
  var withdrawStatus: String? { get }
  var documents: [String]? { get }
  var description: String? { get }
  var missingSteps: [String]? { get }
}

// sourcery: AutoMockable
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
// sourcery: AutoMockable
public protocol AgreementEntity {
  associatedtype Document: DocumentEntity
  var id: String? { get }
  var type: String? { get }
  var documents: [Document]? { get }
  var description: String? { get }
}

  // MARK: - Document
// sourcery: AutoMockable
public protocol DocumentEntity {
  associatedtype File: FileEntity
  var type: String? { get }
  var files: [File]? { get }
}

  // MARK: - File
// sourcery: AutoMockable
public protocol FileEntity {
  var contentType: String? { get }
  var url: String? { get }
  
}

  // MARK: - Limit
// sourcery: AutoMockable
public protocol LimitEntity {
  var period: String? { get }
  var maxAmount: Double? { get }
  var maxTransfer: Double? { get }
  var remainingAmount: Double? { get }
  var remainingTransfer: Double? { get }
}

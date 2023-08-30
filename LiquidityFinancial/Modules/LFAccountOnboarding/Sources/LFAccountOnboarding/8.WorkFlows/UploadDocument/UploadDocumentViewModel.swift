import Foundation
import LFUtilities
import LFLocalizable
import Factory
import NetSpendData
import OnboardingData
import AccountData
import SwiftUI
import UIKit
import UniformTypeIdentifiers

// swiftlint:disable all
@MainActor
final class UploadDocumentViewModel: ObservableObject {
  enum Navigation {
    case documentInReview
    case missingInfo
    case agreement
  }
  
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  
  @Published var navigation: Navigation?
  @Published var isLoading: Bool = false
  @Published var isOpenFileImporterFront: Bool = false
  @Published var isShowDocumentUploadedPopup: Bool = false
  @Published var isDisableButton: Bool = true
  @Published var isShowBottomSheet: Bool = false
  @Published var toastMessage: String?
  @Published var documentTypeSelected: NetSpendDocumentType = .socialSecurityCard
  @Published var documents = [Document]() {
    didSet {
      checkDocumentMaxSize()
    }
  }
  
  var isOpenningDocumentDisplayType: DocumentDisplayType = .none
  
  let documentRequirements: [DocumentRequirement] = [
    DocumentRequirement(
      title: LFLocalizable.UploadDocument.IdentifyRequirement.title,
      details: Constants.identifyVerification
    ),
    DocumentRequirement(
      title: LFLocalizable.UploadDocument.AddressRequirement.title,
      details: Constants.addressVerification
    ),
    DocumentRequirement(
      title: LFLocalizable.UploadDocument.SecondaryRequirement.title,
      details: Constants.secondaryDocument
    ),
    DocumentRequirement(
      title: LFLocalizable.UploadDocument.ProofRequirement.title,
      details: Constants.proofOfNameChange
    ),
    DocumentRequirement(
      title: LFLocalizable.UploadDocument.SsnRequirement.title,
      details: Constants.ssnDocument
    )
  ]
  let documentTypes: [NetSpendDocumentType] = [
    .foreignId, .other, .passport, .payStubDatedWithin30Days, .socialSecurityCard, .stateIssuedPhotoId, .utilityBill
  ]
  
  private var workflowData: APIWorkflowsData?
  
  private let maxSize = Double(Constants.Default.maxSize.rawValue) ?? 20
  
  init() {}
}

  // MARK: Upload document
extension UploadDocumentViewModel {
  private func createDocument(document: Document) -> DocumentEncryptedData {
    var documentEncryptedData = DocumentEncryptedData()
    switch document.documentDisplayType {
    case .front:
      documentEncryptedData.frontImageContentType = document.fileType.getMimeType(from: document.filePath)
      if let data = try? Data(contentsOf: document.filePath) {
        if documentEncryptedData.frontImageContentType == "image/jpeg", let base64EncodedString = UIImage(data: data)?.jpegData(compressionQuality: 1)?.base64EncodedString() {
          documentEncryptedData.frontImage = base64EncodedString
        } else {
          if let datastr = try? Data(contentsOf: document.filePath).base64EncodedString() {
            documentEncryptedData.frontImage = datastr
          }
        }
      }
    case .back:
      documentEncryptedData.backImageContentType = document.fileType.getMimeType(from: document.filePath)
      if let data = try? Data(contentsOf: document.filePath) {
        if documentEncryptedData.backImageContentType == "image/jpeg", let base64EncodedString = UIImage(data: data)?.jpegData(compressionQuality: 1)?.base64EncodedString() {
          documentEncryptedData.backImage = base64EncodedString
        } else {
          if let datastr = try? Data(contentsOf: document.filePath).base64EncodedString() {
            documentEncryptedData.backImage = datastr
          }
        }
      }
    default:
      break
    }
    return documentEncryptedData
  }
  
  func pushDocument(onSuccess: @escaping () -> Void) {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        var documentEncryptedData = DocumentEncryptedData()
        if documents.count == 2 {
          let firstDocumentEncrypted = createDocument(document: documents.first!)
          let lastDocumentEncrypted = createDocument(document: documents.last!)
          documentEncryptedData.frontImageContentType = firstDocumentEncrypted.frontImageContentType
          documentEncryptedData.frontImage = firstDocumentEncrypted.frontImage
          documentEncryptedData.backImageContentType = lastDocumentEncrypted.backImageContentType
          documentEncryptedData.backImage = lastDocumentEncrypted.backImage
        } else if documents.count == 1 {
          let firstDocumentEncrypted = createDocument(document: documents.first!)
          documentEncryptedData.frontImageContentType = firstDocumentEncrypted.frontImageContentType
          documentEncryptedData.frontImage = firstDocumentEncrypted.frontImage
          documentEncryptedData.backImageContentType = firstDocumentEncrypted.backImageContentType
          documentEncryptedData.backImage = firstDocumentEncrypted.backImage
        }
        
        let encryptedData = try netspendDataManager.sdkSession?.encryptWithJWKSet(value: documentEncryptedData.encoded())
        let purpose = netspendDataManager.documentData?.requestedDocuments.first?.workflow ?? ""
        let sessionId = accountDataManager.sessionID
        let documentId = netspendDataManager.documentData?.requestedDocuments.first?.documentRequestId ?? ""
        var isUpdateDocument = false
        if let status = netspendDataManager.documentData?.requestedDocuments.first?.status {
          if status != .open { isUpdateDocument = true }
        }
        let documentData = DocumentParameters(purpose: purpose, documents: [
          DocumentParameters.Document(documentType: documentTypeSelected.rawValue, country: "US", encryptedData: encryptedData ?? "")
        ])
        let path = PathDocumentParameters(sessionId: sessionId, documentID: documentId, isUpdate: isUpdateDocument)
        let postDocument = try await netspendRepository.uploadDocuments(path: path, documentData: documentData)
        
        netspendDataManager.documentData?.update(status: postDocument.status, fromID: postDocument.documentRequestId)
    
        onSuccess()
      } catch {
        log.error(error.localizedDescription)
        toastMessage = error.localizedDescription
      }
    }
  }
}

  // MARK: View Helpers
extension UploadDocumentViewModel {
  
  func handleImportedFile(result: Result<URL, Error>) {
    switch result {
    case let .success(fileURL):
      let document = Document(filePath: fileURL, fileSize: fileURL.size, fileType: documentTypeSelected, documentDisplayType: isOpenningDocumentDisplayType)
      switch document.documentDisplayType {
      case .all, .none: break
      case .front:
        documents.removeAll(where: { $0.documentDisplayType == .front })
        if documents.count == 1 {
          documents.insert(document, at: 0)
        } else if documents.isEmpty {
          documents.append(document)
        }
      case .back:
        documents.removeAll(where: { $0.documentDisplayType == .back })
        if documents.count == 1 {
          documents.insert(document, at: 1)
        } else if documents.isEmpty {
          documents.append(document)
        }
      }
    case let .failure(error):
      toastMessage = error.localizedDescription
    }
  }
  
  func removeFile(index: Int) {
    if documents.indices.contains(index) {
      documents.remove(at: index)
      checkDocumentMaxSize()
    }
  }
  
  func openFileImporter(displayType: DocumentDisplayType) {
    switch displayType {
    case .front:
      log.debug("is import front")
      isOpenningDocumentDisplayType = .front
    case .back:
      log.debug("is import back")
      isOpenningDocumentDisplayType = .back
    case .all:
      isOpenningDocumentDisplayType = .all
    case .none:
      isOpenningDocumentDisplayType = .none
    }
    isOpenFileImporterFront = true
  }
  
  func onClickedDocumentUploadedPrimaryButton() {
    isShowDocumentUploadedPopup = false
    guard let status = netspendDataManager.documentData?.requestedDocuments.first?.status else { return }
    if status == .reviewInProgress {
      navigation = .documentInReview
    } else if status == .open {
      navigation = .documentInReview
    } else if status == .complete {
      onboardingFlowCoordinator.set(route: .kycReview)
    }
    log.info(status.rawValue)
  }
  
  func onUploadDocument() {
    pushDocument(onSuccess: {
      self.documents.removeAll() //reset document selected
      self.isShowDocumentUploadedPopup = true
    })
  }
  
  func showDocumentTypeSheet() {
    isShowBottomSheet = true
  }
  
  func hideDocumentTypeSheet() {
    isShowBottomSheet = false
  }
}

  // MARK: Private Functions
private extension UploadDocumentViewModel {
  func checkDocumentMaxSize() {
    let documentsSize = documents.reduce(0) { currentValue, document in
      currentValue + document.fileSize
    }
    isDisableButton = documentsSize > maxSize || documents.isEmpty
  }
}

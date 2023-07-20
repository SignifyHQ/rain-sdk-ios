import Foundation
import LFUtilities
import LFLocalizable

@MainActor
final class UploadDocumentViewModel: ObservableObject {
  @Published var isOpenFileImporter: Bool = false
  @Published var isShowDocumentUploadedPopup: Bool = false
  @Published var isDisableButton: Bool = true
  @Published var isShowBottomSheet: Bool = false
  @Published var toastMessage: String?
  @Published var documentTypeSelected: DocumentType = .socialSecurityCard
  @Published var documents = [Document]() {
    didSet {
      checkDocumentMaxSize()
    }
  }
  
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
  let documentTypes: [DocumentType] = [
    .foreignID, .other, .passport, .payStub, .socialSecurityCard, .stateID, .utilityBill
  ]
  
  private let maxSize = Double(Constants.Default.maxSize.rawValue) ?? 20
  
  init() {}
}

// MARK: View Helpers
extension UploadDocumentViewModel {
  func handleImportedFile(result: Result<URL, Error>) {
    switch result {
      case let .success(fileURL):
        let document = Document(filePath: fileURL, fileSize: fileURL.size)
        documents.append(document)
      case let .failure(error):
        toastMessage = error.localizedDescription
    }
  }
  
  func removeFile(index: Int) {
    if documents.indices.contains(index) {
      documents.remove(at: index)
    }
  }
  
  func openFileImporter() {
    isOpenFileImporter = true
  }
  
  func onClickedDocumentUploadedPrimaryButton() {
    isShowDocumentUploadedPopup = false
  }
  
  func onUploadDocument() {
    // Handle logic upload document here
    isShowDocumentUploadedPopup = true
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

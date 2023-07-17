import Foundation
import LFUtilities

@MainActor
final class UploadDocumentViewModel: ObservableObject {
  @Published var isOpenFileImporter: Bool = false
  @Published var isShowDocumentUploadedPopup: Bool = false
  @Published var isDisableButton: Bool = true
  @Published var toastMessage: String?
  @Published var documents = [Document]() {
    didSet {
      checkDocumentMaxSize()
    }
  }
  
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

import Foundation

@MainActor
final class UploadDocumentViewModel: ObservableObject {
  @Published var isOpenFileImporter: Bool = false
  @Published var documents = [Document]()

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
        print("error reading file \(error.localizedDescription)")
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
}

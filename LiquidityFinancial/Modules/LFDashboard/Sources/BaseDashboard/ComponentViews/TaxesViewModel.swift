import Foundation
import LFUtilities
import LFLocalizable
import AccountData
import AccountDomain
import Factory

@MainActor
class TaxesViewModel: ObservableObject {
  @Published var status: DataStatus<APITaxFile> = .idle
  @Published var loadingTaxFile: (APITaxFile)?
  @Published var navigation: Navigation?
  @Published var toastMessage: String?
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  lazy var useCase: AccountUseCase = {
    AccountUseCase(repository: accountRepository)
  }()
  
  func onAppear() {
    switch status {
    case .idle:
      apiFetchTaxes()
    default:
      break
    }
  }
  
  func retryTapped() {
    apiFetchTaxes()
  }
  
  func selected(taxFile: APITaxFile) {
    Task { @MainActor in
      defer { loadingTaxFile = nil }
      loadingTaxFile = taxFile
      if let url = fetchLocal(taxFile: taxFile) {
        navigation = .document(name: taxFile.name ?? "", url: url)
      } else {
        guard let accountId = accountDataManager.cryptoAccountID else { return }
        do {
          let result = try await apiFetchDetailTaxes(accountId: accountId, taxFile: taxFile)
          log.debug(result)
          navigation = .document(name: taxFile.name ?? "", url: result)
        } catch {
          toastMessage = "We can get detail the taxes right now so please try it late"
          log.error("Failed to fetch tax document: \(error.localizedDescription)")
        }
      }
    }
  }
}

  // MARK: - Business logic

extension TaxesViewModel {
  private func apiFetchTaxes() {
    guard let accountId = accountDataManager.cryptoAccountID else { return }
    status = .loading
    Task {
      do {
        let taxes = try await useCase.getTaxFile(accountId: accountId).compactMap({ $0 as? APITaxFile })
        status = .success(taxes)
      } catch {
        log.error("Failed to fetch taxes: \(error.localizedDescription)")
        status = .failure(error)
      }
    }
  }
  
  private func fetchLocal(taxFile: APITaxFile) -> URL? {
    do {
      let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
      let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
      return contents.first(where: { $0.description.contains(taxFile.storageName) })
    } catch {
      return nil
    }
  }
  
  private func apiFetchDetailTaxes(accountId: String, taxFile: APITaxFile) async throws -> URL {
    try await useCase.getTaxFileYear(accountId: accountId, year: taxFile.year ?? "", fileName: taxFile.storageName)
  }
}

  // MARK: - Types

extension TaxesViewModel {
  enum Navigation {
    case document(name: String, url: URL)
  }
}

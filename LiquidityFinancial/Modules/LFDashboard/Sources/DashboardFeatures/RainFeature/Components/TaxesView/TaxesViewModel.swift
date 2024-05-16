import Foundation
import LFUtilities
import LFLocalizable
import Factory
import AccountService
import Combine
import ZerohashData
import ZerohashDomain

@MainActor
class TaxesViewModel: ObservableObject {
  @Published var status: DataStatus<APITaxFile> = .idle
  @Published var loadingTaxFile: (APITaxFile)?
  @Published var navigation: Navigation?
  @Published var toastMessage: String?
  @Published var cryptoAccount: AccountModel?
  
  private var cancellable: Set<AnyCancellable> = []
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.zerohashRepository) var zerohashRepository
  
  lazy var getTaxFileUseCase: GetTaxFileUseCaseProtocol = {
    GetTaxFileUseCase(repository: zerohashRepository)
  }()
  
  lazy var getTaxFileYearUseCase: GetTaxFileYearUseCaseProtocol = {
    GetTaxFileYearUseCase(repository: zerohashRepository)
  }()
  
  init() {
    accountDataManager
      .accountsSubject.map({ accounts in
        accounts.first(where: { !$0.currency.isFiat })
      })
      .assign(to: \.cryptoAccount, on: self)
      .store(in: &cancellable)
  }
  
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
        guard let accountId = cryptoAccount?.id else { return }
        do {
          let result = try await apiFetchDetailTaxes(accountId: accountId, taxFile: taxFile)
          log.debug(result)
          navigation = .document(name: taxFile.name ?? "", url: result)
        } catch {
          toastMessage = "We can get detail the taxes right now so please try it late"
          log.error("Failed to fetch tax document: \(error.userFriendlyMessage)")
        }
      }
    }
  }
}

  // MARK: - Business logic

extension TaxesViewModel {
  private func apiFetchTaxes() {
    guard let accountId = cryptoAccount?.id else { return }
    status = .loading
    Task {
      do {
        var taxes = try await self.getTaxFileUseCase.execute(accountId: accountId).compactMap({ $0 as? APITaxFile })
        taxes = taxes.sorted { Int($0.year ?? .empty) ?? 0 > Int($1.year ?? .empty) ?? 0 }
        status = .success(taxes)
      } catch {
        log.error("Failed to fetch taxes: \(error.userFriendlyMessage)")
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
    try await getTaxFileYearUseCase.execute(accountId: accountId, year: taxFile.year ?? "", fileName: taxFile.storageName)
  }
}

  // MARK: - Types

extension TaxesViewModel {
  enum Navigation {
    case document(name: String, url: URL)
  }
}

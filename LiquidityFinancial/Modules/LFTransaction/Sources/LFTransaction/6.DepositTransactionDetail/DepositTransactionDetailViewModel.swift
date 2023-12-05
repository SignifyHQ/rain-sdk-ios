import AccountDomain
import AccountData
import SolidData
import SolidDomain
import NetSpendData
import LFUtilities
import Factory
import Combine

@MainActor
final class DepositTransactionDetailViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.solidExternalFundingRepository) var solidExternalFundingRepository
  
  @Published var isCancelingDeposit = false
  @Published var toastMessage: String?
  @Published var navigation: Navigation?
  @Published var linkedAccount: [APILinkedSourceData] = []
  
  private var cancellable: Set<AnyCancellable> = []
  
  lazy var solidCancelDepositTransactionUseCase: SolidCancelACHTransactionUseCaseProtocol = {
    SolidCancelACHTransactionUseCase(repository: solidExternalFundingRepository)
  }()
  
  init() {
    subscribeLinkedAccounts()
  }
}

// MARK: Functions
extension DepositTransactionDetailViewModel {
  func connectDebitCard() {
    navigation = .addBank
  }
  
  func subscribeLinkedAccounts() {
    accountDataManager.subscribeLinkedSourcesChanged { [weak self] entities in
      guard let self = self else {
        return
      }
      let linkedSources = entities.compactMap({ APILinkedSourceData(entity: $0) })
      linkedAccount = linkedSources
    }
    .store(in: &cancellable)
  }
  
  func cancelDepositTransaction(id: String) {
    Task {
      defer { isCancelingDeposit = false }
      isCancelingDeposit = true
      do {
        _ = try await solidCancelDepositTransactionUseCase.execute(liquidityTransactionID: id)
      } catch {
        guard let errorObject = error.asErrorObject else {
          toastMessage = error.localizedDescription
          return
        }
        toastMessage = errorObject.message
      }
    }
  }
}

// MARK: Types
extension DepositTransactionDetailViewModel {
  enum Navigation {
    case addBank
  }
}

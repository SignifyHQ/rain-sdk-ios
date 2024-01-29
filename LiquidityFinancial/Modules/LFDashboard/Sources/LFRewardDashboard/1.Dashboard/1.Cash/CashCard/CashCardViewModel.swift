import LFUtilities
import Foundation
import AccountData
import SolidData
import SolidDomain
import Factory

@MainActor
public final class CashCardViewModel: ObservableObject {
  @LazyInjected(\.solidCardRepository) var solidCardRepository
  @LazyInjected(\.accountDataManager) var accountDataManager

  @Published var isShowCardDetail = false
  @Published var isCreatingCard = false
  @Published var toastMessage: String?
  
  lazy var createCardUseCase: SolidCreateVirtualCardUseCaseProtocol = {
    SolidCreateVirtualCardUseCase(repository: solidCardRepository)
  }()
  
  public init() {}
}

// MARK: API Functions
extension CashCardViewModel {
  func createCard(onSuccess: @escaping () -> Void) {
    Task {
      defer { isCreatingCard = false }
      isCreatingCard = true
      do {
        let accounts = self.accountDataManager.fiatAccounts
        guard let accountID = accounts.first?.id else {
          return
        }
        _ = try await createCardUseCase.execute(accountID: accountID)
        NotificationCenter.default.post(name: .refreshListCards, object: nil)
        onSuccess()
      } catch {
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}
